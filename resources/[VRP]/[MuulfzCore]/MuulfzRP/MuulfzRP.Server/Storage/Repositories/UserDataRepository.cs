namespace MuulfzRP.Server.Storage
{
    using System;
    using System.Linq;
    using Model;

    public class UserDataRepository : BaseRepository<UserData>
    {
        public UserDataRepository(MuulfzContext dbContext, bool isReadOnly = false) : base(dbContext, isReadOnly)
        {
        }

        public UserData GetByUserId(Guid userId)
        {
           return _dbSet.First(userData => userData.UserId == userId);
        }
    }
}