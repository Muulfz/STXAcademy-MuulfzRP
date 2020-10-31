namespace MuulfzRP.Server.Storage
{
    using System;
    using System.Collections.Generic;
    using System.Data.Entity;
    using System.Linq;
    using System.Threading.Tasks;
    using Core.Model;

    public abstract class BaseRepository<T> : IBaseRepository<T> where T :BaseEntity
    {

        protected readonly DbContext _dbContext;
        protected readonly DbSet<T> _dbSet;
        private readonly bool _isReadOnly;

        protected BaseRepository(MuulfzContext dbContext, bool isReadOnly = false)
        {
            _dbContext = dbContext;
            _isReadOnly = isReadOnly;
            _dbSet = dbContext.Set<T>();
        }

        protected IQueryable<T> Query => _isReadOnly ? _dbSet.AsNoTracking() : _dbSet;

        public void Add(T entity)
        {
            _dbSet.Add(entity);
        }

        public void AddRange(T[] objects)
        {
            _dbSet.AddRange(objects);
        }

        public IEnumerable<T> All()
        {
            return Query.ToList();
        }

        public async Task<IEnumerable<T>> AllAsync()
        {
            return await Query.ToListAsync().ConfigureAwait(true);
        }

        public void SaveChanges()
        {
            _dbContext.SaveChanges();
        }

        public T FindById(Guid id)
        {
            return Query.SingleOrDefault(t => t.Id == id);
        }
    }
}