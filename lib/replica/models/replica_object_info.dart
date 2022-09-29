class ReplicaObjectInfo {
  ReplicaObjectInfo(
    this.infoDescription,
    this.infoTitle,
    this.infoCreationDate,
  );

  late String infoDescription;
  late String infoTitle;
  late String infoCreationDate;
}

class EmptyReplicaObjectInfo extends ReplicaObjectInfo {
  EmptyReplicaObjectInfo() : super('', '', '');
}
