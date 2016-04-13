using System;
using System.Collections.Generic;
using sapi_websocket.synthesizer.player;

namespace sapi_websocket.synthesizer
{
    /// <summary>
    /// Speech synthesizer capable of simultaneous playback of multiple sounds and audio panning.
    /// </summary>
    class MultiplexSynthesizer
    {
        //maps user id to player
        private Dictionary<string, SpeechPlayer> players;

        /// <summary>
        /// Occurs when playback starts
        /// </summary>
        public event EventHandler<SpeechStateEventArgs> SpeakStarted;

        /// <summary>
        /// Occurs when playback completes
        /// </summary>
        public event EventHandler<SpeechStateEventArgs> SpeakCompleted;

        ///// <summary>
        ///// Occurs when playback state changes
        ///// </summary>
        public event EventHandler<SpeechStateEventArgs> StateChanged;

        /// <summary>
        /// Constructor
        /// </summary>
        public MultiplexSynthesizer()
        {
            players = new Dictionary<string, SpeechPlayer>();
        }      

        /// <summary>
        /// Play audio generated from text
        /// </summary>
        /// <param name="textToSpeak">string reference of SSML object</param>
        public void Speak(string textToSpeak)
        {
            TTSMessage message = new TTSMessage(textToSpeak);
            OutputSource(message);
        }

        /// <summary>
        /// Stops all players
        /// </summary>
        public void Cancel()
        {
            foreach (KeyValuePair<string, SpeechPlayer> entry in players)
            {
                entry.Value.Stop();
            }
        }

        /// <summary>
        /// Queue playback of TTS audio
        /// </summary>        
        /// <param name="message">TTSMessage to output</param>
        private void OutputSource(TTSMessage message)
        {            
            //access and load player with provided message
            SpeechPlayer player = GetPlayer(message.User);          
            player.Load(message);
        }

        /// <summary>
        /// Returns <see cref="SpeechPlayer"/> corresponding to the provided id 
        /// </summary>
        /// <param name="id">player id</param>
        /// <returns>Intance of <see cref="SpeechPlayer"/> with provided id</returns>
        private SpeechPlayer GetPlayer(string id)
        {
            SpeechPlayer player;

            //return existing player
            if (players.ContainsKey(id))
            {
                player = players[id];
            }
            //register new player
            else
            {
                player = new SpeechPlayer(id);
                player.StateChanged += new EventHandler<SpeechStateEventArgs>(OnStateChanged);
                players[id] = player;
            }

            return player;
        }

        /// <summary>
        /// Call appropriate events
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnStateChanged(object sender, SpeechStateEventArgs e)
        {
            switch (e.State)
            {
                case SpeechPlayerState.Playing:
                    SpeakStarted(this, e);
                    break;
                case SpeechPlayerState.Complete:
                    SpeakCompleted(this, e);
                    break;
                default:
                    break;
            }
            StateChanged(this, e);
        }

        /// <summary>
        /// Time required to close players
        /// </summary>
        public int CloseTime
        {
            get { return players.Count * 1000; }
        }

        /// <summary>
        /// Close players
        /// </summary>
        public void Close()
        {
            foreach (KeyValuePair<string, SpeechPlayer> entry in players)
            {
                entry.Value.Close();                
            }
            players.Clear();
        }
    }
}
