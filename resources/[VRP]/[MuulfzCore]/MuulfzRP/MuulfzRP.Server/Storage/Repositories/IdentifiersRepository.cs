namespace MuulfzRP.Server.Storage
{
    using Model;

    public class IdentifiersRepository : BaseRepository<Identifier>
    {
        public IdentifiersRepository(MuulfzContext dbContext, bool isReadOnly = false) : base(dbContext, isReadOnly)
        {
        }

    }
}