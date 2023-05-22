class GroupSummary {
  final Map<String, double> saldo;

  GroupSummary(this.saldo);

  factory GroupSummary.fromData(Map<String, dynamic> data) {
    List<dynamic> saldosList = data["saldos"];

    Map<String, double> saldos = {};

    for (var entry in saldosList) {
      var dynamicSaldo = entry["saldo"];

      saldos[entry["name"]] = switch (dynamicSaldo.runtimeType) {
        double => dynamicSaldo,
        int => (dynamicSaldo as int).toDouble(),
        _ => 0
      };
    }

    return GroupSummary(saldos);
  }
}
