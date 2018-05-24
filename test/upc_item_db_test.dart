import 'package:test/test.dart';

import '../lib/upc_item_db.dart';

void main() {
  test('check default config', () {
    final db = new UpcItemDB();
    expect(db.trial, true);
    expect(db.baseUrl, "https://api.upcitemdb.com/prod");
    expect(db.trialPath, "/trial");
    expect(db.paidPath, "/v1");
  });
  test('lookup valid code', () {
    UpcItemDB db = new UpcItemDB();
    final barcode = "4002293401102";
    db.lookup(barcode).then(expectAsync1((response) {
      expect(response is ItemsResponse, true);
      expect(response.items.length, greaterThan(0));
    }));
  });
  test('lookup invalid code', () {
    UpcItemDB db = new UpcItemDB();
    final barcode = "999999999999";
    db.lookup(barcode).catchError((e) {
      expect(e is ErrorResponse, true);
    });
  });
}
