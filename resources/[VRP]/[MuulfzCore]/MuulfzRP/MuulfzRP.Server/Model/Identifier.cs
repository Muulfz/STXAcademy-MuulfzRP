namespace MuulfzRP.Server.Model
{
    using System;
    using System.Collections;
    using CitizenFX.Core;
    using Core.Model;

    public class Identifier : BaseEntity
    {
        public Guid UserId { get; set; }
        public virtual User User { get; set; }
        public string SteamId { get; set; }
        public string License { get; set; }
        public string Discord { get; set; }
        public string XboxLive { get; set; }
        public string LiveId { get; set; }
        public string Ip { get; set; }

        public Identifier(IdentifierCollection identifier)
        {
            SteamId = identifier["steam"];

            Console.WriteLine(identifier.GetEnumerator().ToString());
            //TODO GERAR ESSE METDO
        }
    }
}