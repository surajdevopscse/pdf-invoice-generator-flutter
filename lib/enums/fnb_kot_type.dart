enum KotType {
  create('Create'),
  add('Update'),
  update('Update'),
  cancel('Cancel');

  final String title;
  const KotType(this.title);
}