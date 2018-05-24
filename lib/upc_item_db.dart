library upc_item_db;

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:money/money.dart';

class UpcItemDB {
  final String baseUrl = "https://api.upcitemdb.com/prod";
  final String trialPath = "/trial";
  final String paidPath = "/v1";

  String userKey;
  bool trial = true;
  int _lastRequest = 0;
  http.Client _httpClient;

  UpcItemDB() {
    _httpClient = new http.Client();
  }

  Map<String, String> header = {
    "Accept": "application/json",
    'Content-Type': 'application/json',
    'key_type': "3scale"
  };

  void enablePaidPlan(String key) {
    userKey = key;
    header['user_key'] = userKey;
    trial = false;
  }

  // code can be UPC, ISBN or EAN
  Future<ItemsResponse> lookup(String code) async {
    String url = baseUrl + (trial ? trialPath : paidPath) + "/lookup?upc=$code";
    return httpGet(url, _httpClient);
  }

  Future<ItemsResponse> search(String searchRequest) async {
    String url =
        baseUrl + (trial ? trialPath : paidPath) + "/lookup?s=$searchRequest";
    return httpGet(url, _httpClient);
  }

  Future<ItemsResponse> httpGet(String url, http.Client client) async {
    int now = new DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRequest < 1000 / 6) {
      print(
          'Exceeded burst limit of UpcItemDB API. Max. 6 requests per second.');
      return null;
    }
    http.Response httpResponse = await client.get(url, headers: header);
    _lastRequest = now;
    Map<String, dynamic> data = json.decode(httpResponse.body);
    if (httpResponse.statusCode == 200) {
      return ItemsResponse.fromJson(data);
    } else {
      throw new ErrorResponse.fromJson(data);
    }
  }
}

class ItemsResponse {
  final String code;
  final int total;
  final int offset;
  final List<Item> items;

  ItemsResponse(this.code, this.total, this.offset, this.items);

  factory ItemsResponse.fromJson(Map<String, dynamic> json) {
    return new ItemsResponse(json['code'], json['total'], json['offset'],
        json['items'].map<Item>((item) => new Item.fromJson(item)).toList());
  }
}

class ErrorResponse {
  final String code;
  final String message;

  ErrorResponse(this.code, this.message);

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return new ErrorResponse(json['code'], json['message']);
  }
}

class Item {
  final String ean;
  final String title;
  final String description;
  final String brand;
  final String model;
  final String color;
  final String size;
  final String dimension;
  final String weight;

  Money lowestRecordedPrice;
  Money highestRecordedPrice;

  String currency;
  String upc;
  String gtin;
  String elid;
  String userData;

  List<String> images;
  List<Offer> offers;

  Item(this.ean, this.title, this.description, this.brand, this.model,
      this.color, this.size, this.dimension, this.weight);

  factory Item.fromJson(Map<String, dynamic> json) {
    Item item = new Item(
        json['ean'],
        json['title'],
        json['description'],
        json['brand'],
        json['model'],
        json['color'],
        json['size'],
        json['dimension'],
        json['weight']);

    if (json.containsKey('currency') &&
        json.containsKey('lowest_recorded_price') &&
        json.containsKey('highest_recorded_price')) {
      String currencyString = json['currency'];
      currencyString = currencyString.trim();
      final double low = json['lowest_recorded_price'];
      final double high = json['highest_recorded_price'];
      Currency currency;

      try {
        currency = new Currency(currencyString);
      } on ArgumentError {
        print('Unknown currency code.');
      }

      if (currency != null) {
        // Assumes prices to be in "2.99" format
        item.highestRecordedPrice = new Money((high * 100).toInt(), currency);
        item.lowestRecordedPrice = new Money((low * 100).toInt(), currency);
      }
    }
    if (json.containsKey('upc')) {
      item.upc = json['upc'];
    }
    if (json.containsKey('gtin')) {
      item.gtin = json['gtin'];
    }
    if (json.containsKey('elid')) {
      item.elid = json['elid'];
    }
    if (json.containsKey('user_data')) {
      item.userData = json['user_data'];
    }
    if (json.containsKey('images')) {
      final img = new List<String>.from(json['images']);
      if (img.isNotEmpty) {
        item.images = img;
      }
    }
    if (json.containsKey('offers')) {
      item.offers = json['offers']
          .map<Offer>((offer) => new Offer.fromJson(offer))
          .toList();
    }

    return item;
  }
}

class Offer {
  final String merchant;
  final String domain;
  final String title;
  final String currency;
  final String shipping;
  final String condition;
  final String availability;
  final String link;
  final int updatedTime;
  final listPrice;
  final price;

  Offer(
      this.merchant,
      this.domain,
      this.title,
      this.currency,
      this.shipping,
      this.condition,
      this.availability,
      this.link,
      this.listPrice,
      this.price,
      this.updatedTime);

  factory Offer.fromJson(Map<String, dynamic> json) {
    return new Offer(
        json['merchant'],
        json['domain'],
        json['title'],
        json['currency'],
        json['shipping'],
        json['condition'],
        json['availability'],
        json['link'],
        json['list_price'],
        json['price'],
        json['updated_t']);
  }
}
