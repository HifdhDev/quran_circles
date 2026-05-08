import '../entities/student.dart';

abstract class IStudentRepository {
  Future<List<Student>> getAll({bool? activeOnly});
  Future<Student?> getById(int id);
  Future<int> add(Student student);
  Future<void> update(Student student);
  Future<void> delete(int id);
  Future<List<Student>> search(String query);
}
