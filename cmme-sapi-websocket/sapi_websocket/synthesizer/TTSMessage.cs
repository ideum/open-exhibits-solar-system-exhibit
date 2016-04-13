using System;
using System.Xml;

namespace sapi_websocket.synthesizer
{
    class TTSMessage
    {
        /// <summary>
        /// Text-to-Speech object
        /// </summary>
        /// <param name="SSMLString"></param>
        public TTSMessage(string SSMLString)
        {
            Text = SSMLString;
            TTSAttributes(Text);
        }

        /// <summary>
        /// Text to speak
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// Id of targeted player
        /// </summary>
        public string User { get; set; }

        /// <summary>
        /// Audio panning value from -1 to 1
        /// </summary>
        public int Pan { get; set; }

        /// <summary>
        /// Flag indicating the message will interrupt and replace the current queue
        /// </summary>
        public bool Preempt { get; set; }

        /// <summary>
        /// Parses provided SSML object for TTS prosody settings
        /// </summary>
        /// <param name="value">string reference of SSML object</param>
        private void TTSAttributes(string value)
        {
            try
            {
                XmlDocument xml = new XmlDocument();
                xml.LoadXml(value);
                XmlNode node = xml.GetElementsByTagName("prosody")[0];
                XmlAttributeCollection attrs = node.Attributes;

                User = attrs["user"] == null ? "0" : attrs["user"].Value;
                Pan = attrs["pan"] == null ? 0 : int.Parse(attrs["pan"].Value);
                Preempt = attrs["preempt"] == null ? false : bool.Parse(attrs["preempt"].Value);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.StackTrace);
            }

        }
    }
}
