class ReplicaObjectInfo {
  ReplicaObjectInfo(
    this.description,
    this.title,
    this.creationDate,
  );

  late String description;
  late String title;
  late String creationDate;
}

ReplicaObjectInfo EmptyReplicaObjectInfo() {
  return ReplicaObjectInfo('', '', '');
}
