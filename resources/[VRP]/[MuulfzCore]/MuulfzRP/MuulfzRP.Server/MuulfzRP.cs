namespace MuulfzRP.Server
{
    using System;
    using System.Collections.Generic;

    public class MuulfzRP
    {
        /// <summary>
        /// SOURCE / USER ID
        /// </summary>
        public static Dictionary<string, Guid> Users { get; set; }
        /// <summary>
        ///  USER ID | SOURCE 
        /// </summary>
        public static Dictionary<Guid, string> Sources { get; set; }

    }
}