class GroupSummary {
  final Map<String, double> saldo;

  GroupSummary(this.saldo);

  factory GroupSummary.fromData(Map<String, dynamic> data) {
    List<dynamic> saldosList = data["saldos"];

    Map<String, double> saldos = {};

    for (var s in saldosList) {
      saldos[s["name"]] = s["saldo"];
    }

    return GroupSummary(saldos);
  }
}
