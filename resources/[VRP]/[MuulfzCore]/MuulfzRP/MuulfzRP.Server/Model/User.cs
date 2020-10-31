namespace MuulfzRP.Server.Model
{
    using System;
    using System.Collections.Generic;
    using Core.Model;

    public class User : BaseEntity
    {
        public string Name { get; set; }
        public int Source { get; set; }
        public string EndPoint { get; set; }
        public bool LoadingCharacter { get; set; } = false;
        public bool Banned { get; set; } = false;
        public bool Whitelisted { get; set; } = true;
        public virtual Identifier Identifier { get; set; }

        public virtual List<Character> characters { get; set; }
        public virtual UserData UserData { get; set; }
        public DateTime LastLogin { get; set; }

        public User(Identifier identifier)
        {
            this.Identifier = identifier;
        }

        public bool IsReady()
        {
            return Id != Guid.Empty && !LoadingCharacter;
        }
    }

    public class Character : BaseEntity
    {
        public virtual User User { get; set; }
        public Guid UserId { get; set; }
    }
}