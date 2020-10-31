namespace MuulfzRP.Server.Storage
{
    using System.Data.Entity;
    using Model;

    public class MuulfzContext : DbContext
    {
        public DbSet<User> Users { get; set; }
        public DbSet<Identifier> Identifiers { get; set; }
        public DbSet<UserData> UserDatas { get; set; }


        protected MuulfzContext()
        {
            Database.Connection.ConnectionString =
                $"Server=localhost;Port=3306;User ID=root;Password=macaco;Database=MuulfzDB";

            Database.CreateIfNotExists();
        }
    }
}