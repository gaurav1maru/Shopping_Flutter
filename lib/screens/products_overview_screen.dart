import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  _updateFavoriteValue(FilterOptions value) {
    _showOnlyFavorites = (value == FilterOptions.Favorites);

    // if (value == FilterOptions.Favorites) {
    //   _showOnlyFavorites = true;
    // } else {
    //   _showOnlyFavorites = false;
    // }
    // print("_showOnlyFavorites = $_showOnlyFavorites");
  }

  @override
  void initState() {
    //Provider.of<Products>(context).fetchAndSetProducts();//WON'T WORK

    //Hack
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //Don't use async await here as these methods are already defined in the parent class
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().catchError((error) {
        setState(() {
          _isLoading = false;
        });

        /**test start */
        // ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //     "An error occurred: ${error.toString()}",
        //   ),
        //   duration: Duration(seconds: 5),
        // ));
        /**test end */
        
      }).then((_) {
        // setState(() {
        //   /**test start */
        //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text(
        //       "Response type: ${Provider.of<Products>(context, listen: false).getType}",
        //     ),
        //     duration: Duration(seconds: 5),
        //   ));
        //   /**test end */
        // });

        // showDialog<Null>(
        //     context: context,
        //     builder: (ctx) => AlertDialog(
        //           title: Text("An error occurred!"),
        //           content: Text(
        //               "Response type: ${Provider.of<Products>(context).getType}"),
        //           actions: [
        //             FlatButton(
        //                 onPressed: () {
        //                   Navigator.of(ctx).pop();
        //                 },
        //                 child: Text("OK"))
        //           ],
        //         ));

        setState(() {
          _isLoading = false;
        });
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //   final productsData = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My shop"),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  _updateFavoriteValue(selectedValue);
                });

                /**don't do it globally. do it locally */
                // if (selectedValue == FilterOptions.Favorites) {
                //   productsData.showFavoritesOnly();
                // } else {
                //   productsData.showAll();
                // }
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text("Only Favorites"),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text("Show All"),
                      value: FilterOptions.All,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (_, cartData, childWidget) =>
                Badge(child: childWidget, value: cartData.itemCount.toString()),
            //static content
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart)),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
