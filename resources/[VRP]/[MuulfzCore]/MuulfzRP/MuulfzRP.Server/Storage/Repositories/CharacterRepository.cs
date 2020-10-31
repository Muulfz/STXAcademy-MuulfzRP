namespace MuulfzRP.Server.Storage
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using Model;

    public class CharacterRepository : BaseRepository<Character>
    {
        public CharacterRepository(MuulfzContext dbContext, bool isReadOnly = false) : base(dbContext, isReadOnly)
        {
        }


        public List<Character> FindAllByUser(Guid id)
        {
            return _dbSet.Where(e => e.UserId == id).ToList();
        }
    }
}