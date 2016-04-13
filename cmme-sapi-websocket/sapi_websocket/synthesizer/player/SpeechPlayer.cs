using System;
using System.Threading;
using System.IO;
using System.Collections.Generic;
using CSCore;
using CSCore.Codecs;
using CSCore.SoundOut;
using CSCore.Streams;
using Microsoft.Speech.Synthesis;
using Microsoft.Speech.AudioFormat;

namespace sapi_websocket.synthesizer.player
{
    /// <summary>
    /// Manages text-to-speech and playback operations
    /// </summary>
    class SpeechPlayer
    {
        private string output;
        private string id;
        private IWaveSource source;
        private ISoundOut sound;
        private Thread playback;
        private SpeechSynthesizer synthesizer;
        private SpeechPlayerState state;
        private double duration;
        private bool autoplay;

        //audio panning between stereo channels (value between -1 and 1), set through SSML message
        private int pan;

        //message queue
        private Queue<TTSMessage> queue;
        
        /// <summary>
        /// Subscribe to state changes
        /// </summary>
        public event EventHandler<SpeechStateEventArgs> StateChanged;


        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="id">player id</param>
        /// <param name="pan">optional audio pan setting</param> 
        public SpeechPlayer(string id, bool autoplay = true)
        {
            output = Server.AudioFilePath+"\\source_" + id + ".wav";
            synthesizer = GetSynthesizer();
            this.id = id;
            this.autoplay = autoplay;
            SpeechState = SpeechPlayerState.Ready;
            queue = new Queue<TTSMessage>();
        }

        /// <summary>
        /// Player id
        /// </summary>
        public string ID
        {
            get { return id; }
        }

        /// <summary>
        /// Output .wav file 
        /// </summary>
        public string Output
        {
            get { return output; }
        }

        /// <summary>
        /// Play on load
        /// </summary>
        public bool Autoplay{
            get { return autoplay; }
            set { autoplay = value; }
        }

        /// <summary>
        /// Current player state
        /// </summary>
        public SpeechPlayerState State
        {
            get { return state; }
        }

        /// <summary>
        /// Internal state change
        /// </summary>
        private SpeechPlayerState SpeechState
        {
            set 
            {
                if (value != state)
                {
                    state = value;
                    if (StateChanged != null)
                    {
                        SpeechStateEventArgs e = new SpeechStateEventArgs() { User = id, State = state, Duration = duration };
                        StateChanged(this, e);
                    }
                }            
            }
        }

        /// <summary>
        /// Returns a <see cref="Microsoft.Speech.Synthesis.SpeechSynthesizer"/> instance
        /// </summary>
        /// <returns></returns>
        private SpeechSynthesizer GetSynthesizer()
        {
            SpeechSynthesizer s = new SpeechSynthesizer();
            s.SelectVoiceByHints(VoiceGender.NotSet);
            s.SpeakStarted += new EventHandler<SpeakStartedEventArgs>(LoadStart);
            s.SpeakCompleted += new EventHandler<SpeakCompletedEventArgs>(LoadCompete);
            return s;
        }

        /// <summary>
        /// Load TTS message to convert to audio output
        /// </summary>
        /// <param name="message">message to convert</param>
        public void Load(TTSMessage message){

            //abort processing of null message
            if (message == null){ return;}

            //audio panning
            pan = message.Pan;

            //queue operations
            if (message.Preempt)
            {
                PreemptQueue();
            }
            else 
            {
                AddToQueue(message);
            }             

            //generate speech wav file
            if(state.Equals(SpeechPlayerState.Ready))
            { 
                synthesizer.SetOutputToWaveFile(output, new SpeechAudioFormatInfo(22050, AudioBitsPerSample.Sixteen, AudioChannel.Stereo));
                synthesizer.SpeakSsmlAsync(message.Text);
            }
        }

        /// <summary>
        /// Audio output generation initialized
        /// </summary>
        /// <param name="sender">Dispatching object</param>
        /// <param name="e">Event arguments</param>
        private void LoadStart(object sender, SpeakStartedEventArgs e)
        {
            duration = 0.0;
            SpeechState =  SpeechPlayerState.Loading;
        }

        /// <summary>
        /// Audio ouput generation complete
        /// </summary>
        /// <param name="sender">Dispatching object</param>
        /// <param name="e">Event arguments</param>
        private void LoadCompete(object sender, SpeakCompletedEventArgs e)
        {
            //release ouput source
            synthesizer.SetOutputToNull();

            //update state
            SpeechState =  SpeechPlayerState.Ready;
            
            //autoplay
            if (autoplay)
            {
                Play();
            }
        }

        /// <summary>
        /// Clear queue and stop playback
        /// </summary>
        private void PreemptQueue()
        {
            //interrupt if speaking
            if (synthesizer.State.Equals(SynthesizerState.Speaking))
            {
                synthesizer.Dispose();
                synthesizer = GetSynthesizer();
            }

            //clear queue here
            Stop();
            queue.Clear();
            state = SpeechPlayerState.Ready;
        }

        /// <summary>
        /// Add message to speech queue
        /// </summary>
        /// <param name="message">message to add</param>
        private void AddToQueue(TTSMessage message)
        {
            if (!state.Equals(SpeechPlayerState.Ready))
            {
                queue.Enqueue(message);
            }
        }

        /// <summary>
        /// Start playback
        /// </summary>
        public void Play()
        {
            if (state.Equals(SpeechPlayerState.Ready))
            {
                playback = new Thread(new ThreadStart(StartSound));
                playback.Start();
                while (!playback.IsAlive) ;
                Thread.Sleep(1);
            }
        }

        /// <summary>
        /// Stop playback
        /// </summary>
        public void Stop()
        {
            if (sound != null)
            {               
                sound.Dispose();
                source.Dispose();
                playback.Abort();
            }
        }

        /// <summary>
        /// Execute playback in seperate thread
        /// </summary>
        private void StartSound()
        {
            using (source = GetSource())
            {
                duration = source.GetLength().TotalSeconds;
                using (sound = GetSoundOut())
                {
                    sound.Initialize(source);
                    sound.Play();
                    SpeechState = SpeechPlayerState.Playing;
                    Thread.Sleep((int)source.GetLength().TotalMilliseconds);
                }
            }
            PlaybackComplete();            
        }

        /// <summary>
        /// Return ISoundOut instance for audio playback
        /// </summary>
        /// <returns></returns>
        private ISoundOut GetSoundOut()
        {
            if (WasapiOut.IsSupportedOnCurrentPlatform)
                return new WasapiOut() { Latency = 200 };
            else
                return new DirectSoundOut() { Latency = 200 };
        }

        /// <summary>
        /// Returns output codec to play
        /// </summary>
        /// <returns></returns>
        private IWaveSource GetSource()
        {
            IWaveSource codec = CodecFactory.Instance.GetCodec(output);
            PanSource ps = new PanSource(codec);
            ps.Pan = pan;
            return ps.ToWaveSource();
        }

        /// <summary>
        /// Update player state and queue next message
        /// </summary>
        private void PlaybackComplete()
        {
            //update state
            SpeechState = SpeechPlayerState.Complete;
            SpeechState = SpeechPlayerState.Ready;          

            //queue next message    
            if (queue.Count > 0)
            {
                Load(queue.Dequeue());
            }

            //terminate playback
            playback.Abort();  
        }

        /// <summary>
        /// Release generated audio file and delete from disk
        /// </summary>
        public void Close()
        {
            Stop();
            synthesizer = GetSynthesizer();
            File.Delete(output);
        }
    }
}
