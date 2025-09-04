// Services/Firebase/FirebaseHelper.cs
using Google.Cloud.Firestore;
using System.Text.Json;

namespace SkillsAuditSystem.Services.Firebase
{
    public static class FirebaseHelper
    {
        public static string GenerateId()
        {
            return Guid.NewGuid().ToString("N");
        }

        public static Dictionary<string, object> ConvertToDictionary<T>(T obj)
        {
            var json = JsonSerializer.Serialize(obj);
            return JsonSerializer.Deserialize<Dictionary<string, object>>(json) ?? new Dictionary<string, object>();
        }

        public static T ConvertFromDictionary<T>(Dictionary<string, object> dictionary)
        {
            var json = JsonSerializer.Serialize(dictionary);
            return JsonSerializer.Deserialize<T>(json)!;
        }

        public static Query ApplyPagination(Query query, int pageSize = 10, DocumentSnapshot? lastDocument = null)
        {
            if (lastDocument != null)
            {
                query = query.StartAfter(lastDocument);
            }

            return query.Limit(pageSize);
        }

        public static Query ApplyOrdering(Query query, string field, bool ascending = true)
        {
            return ascending ? query.OrderBy(field) : query.OrderByDescending(field);
        }

        public static Query ApplyDateFilter(Query query, string field, DateTime? startDate, DateTime? endDate)
        {
            if (startDate.HasValue)
            {
                query = query.WhereGreaterThanOrEqualTo(field, startDate.Value);
            }

            if (endDate.HasValue)
            {
                query = query.WhereLessThanOrEqualTo(field, endDate.Value);
            }

            return query;
        }

        public static async Task<List<T>> ExecuteQueryAsync<T>(Query query) where T : class
        {
            try
            {
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(doc => doc.ConvertTo<T>()).ToList();
            }
            catch (Exception)
            {
                return new List<T>();
            }
        }

        public static async Task<(List<T> items, DocumentSnapshot? lastDocument)> ExecutePaginatedQueryAsync<T>(
            Query query, int pageSize = 10) where T : class
        {
            try
            {
                var snapshot = await query.Limit(pageSize).GetSnapshotAsync();
                var items = snapshot.Documents.Select(doc => doc.ConvertTo<T>()).ToList();
                var lastDocument = snapshot.Documents.LastOrDefault();

                return (items, lastDocument);
            }
            catch (Exception)
            {
                return (new List<T>(), null);
            }
        }

        public static async Task<bool> DocumentExistsAsync(DocumentReference documentRef)
        {
            try
            {
                var snapshot = await documentRef.GetSnapshotAsync();
                return snapshot.Exists;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static WriteBatch CreateBatch(FirestoreDb db)
        {
            return db.StartBatch();
        }

        public static async Task<bool> ExecuteBatchAsync(WriteBatch batch)
        {
            try
            {
                await batch.CommitAsync();
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}