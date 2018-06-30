Flutter wrapper for the [UPCitemdb](http://www.upcitemdb.com) API.

Note: This is **unofficial, experimental, non-production** code. 

# Getting started
For help getting started with Flutter, view the online [documentation](https://flutter.io/docs).

Clone this repository into your app's `lib/src/lib` and use it like in this example:

```dart
import './src/lib/upc_item_db/lib/upc_item_db.dart';

UpcItemDb db = new UpcItemDB();
ItemsResponse response;

try {
    response = await db.lookup(barcode);
} on ErrorResponse catch (e) {
    // Exceeded rate limit or item not found
    print(e.code + ': ' + e.message)
}
if (response != null) {
    // Item lookup successful
    Item firstItem = response.items[0];
    print(firstItem.title);
}
```

# Methods

## lookup()
Accepts a barcode string (UPC, ISBN or EAN).

```dart
UpcItemDb db = new UpcItemDB();
ItemsResponse response = await db.lookup(barcode);
```

## search()
Accepts a search string.

```dart
UpcItemDb db = new UpcItemDB();
ItemsResponse response = await db.lookup(barcode);
```

# Response Objects

## ItemsResponse
Contains a list of 0..n matched items.

```dart
class ItemsResponse {
    String code;
    int total;
    int offset; 
    List<Item> items;
}
```

## Item
Matched item with default properties. (There may be more)

```dart
class Item {
    String ean;
    String title;
    String description;
    String brand;
    String model;
    String color;
    String size;
    String dimension;
    String weight;
}
```

# Contributing
For help on editing package code, view the Flutter [documentation](https://flutter.io/developing-packages/).
