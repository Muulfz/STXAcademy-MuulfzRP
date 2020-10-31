namespace MuulfzRP.Server.Storage
{
    using System.Linq;
    using Core.Model;
    using Model;

    public class UserRepository : BaseRepository<User>
    {
        public UserRepository(MuulfzContext dbContext, bool isReadOnly = false) : base(dbContext, isReadOnly)
        {
        }

        public User FindUserByIdentifier(Identifier identifier)
        {
            return _dbSet.First(u => u.Identifier.License == identifier.License);
            //TODO APRIMORAR ESSA QUERRY
        }

        public User FindUserOrCreateNew(Identifier identifier)
        {
            User findUserByIdentifier = FindUserByIdentifier(identifier);
            if (findUserByIdentifier != null)
            {
                return findUserByIdentifier;
            }

            return new User(identifier);
        }
    }
}