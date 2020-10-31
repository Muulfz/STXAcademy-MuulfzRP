namespace MuulfzRP.Server.Model
{
    using System;
    using Core.Model;

    public class UserData : BaseEntity
    {
        public Guid UserId { get; set; }
        public virtual User User { get; set; }
        public Guid CurrentCharacter { get; set; }
    }
}