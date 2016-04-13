using System;

namespace sapi_websocket.synthesizer.player
{
    /// <summary>
    /// Arguments specifying speech player and current state
    /// </summary>
    class SpeechStateEventArgs:EventArgs
    {
        /// <summary>
        /// Player id
        /// </summary>
        public string User { get; set; }

        /// <summary>
        /// Current state of player
        /// </summary>
        public SpeechPlayerState State { get; set; }

        /// <summary>
        /// Playback duration
        /// </summary>
        public double Duration { get; set; }
    }
}
