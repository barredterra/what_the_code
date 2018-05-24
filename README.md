Flutter package for the [UPCitemdb](http://www.upcitemdb.com) API.

Note: This is a work in progress and experimental.

Example:

	import 'package:upc_item_db/upc_item_db.dart';
	import 'package:http'
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

For help getting started with Flutter, view the online [documentation](https://flutter.io/docs).

# Methods

## lookup()

	UpcItemDb db = new UpcItemDB();
	ItemsResponse response = await db.lookup(barcode);

## search()

	final UpcItemDb db = new UpcItemDB();
	final ItemsResponse response = await db.lookup(barcode);

# Objects

## ItemsResponse
Contains a list of 0..n matched items.

	class ItemsResponse {
	    String code;
	    int total;
	    int offset; 
	    List<Item> items;
	}


## Item
Matched item with default properties. (There may be more)

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


# Contributing
For help on editing package code, view the Flutter [documentation](https://flutter.io/developing-packages/).
