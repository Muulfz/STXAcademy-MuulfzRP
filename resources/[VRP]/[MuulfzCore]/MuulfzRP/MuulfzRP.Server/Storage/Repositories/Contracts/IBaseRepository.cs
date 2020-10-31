namespace MuulfzRP.Server.Storage
{
    using System;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Core.Model;

    public interface IBaseRepository<T> where  T: BaseEntity
    {
        T FindById(Guid id);

        void Add(T entity);

        void AddRange(T[] entities);

        IEnumerable<T> All();

        Task<IEnumerable<T>> AllAsync();

        void SaveChanges();
    }
}