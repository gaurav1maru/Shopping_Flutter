import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (ctx) => ProductDetailScreen(title)));
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          // child: Image.network(
          //   product.imageUrl,
          //   fit: BoxFit.cover,
          // ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
              //Only part of a widget listen to changes
              //child can be used to take out static part of the widget the consumer is wrappeed around
              /**eg.
               * if IconButton had a label which contains static text then
               * label: child,//on IconButton
               * ...,
               * child: Text("abc")//on Consumer
               */
              builder: (ctx, product, child) => IconButton(
                  onPressed: () {
                    product.toggleFavoriteStatus(
                        authData.token, authData.userId);
                  },
                  icon: Icon(
                    product.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).accentColor,
                  ))),
          trailing: IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Added item to the cart",
                  ),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                  duration: Duration(seconds: 2),
                ));
              },
              icon: Icon(Icons.shopping_cart)),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    /**using only Consumer */
    // return Consumer<Product>(
    //     builder: (ctx, product, child) => ClipRRect(
    //           borderRadius: BorderRadius.circular(10),
    //           child: GridTile(
    //             child: GestureDetector(
    //               onTap: () {
    //                 // Navigator.of(context).push(MaterialPageRoute(
    //                 //     builder: (ctx) => ProductDetailScreen(title)));
    //                 Navigator.of(context).pushNamed(
    //                     ProductDetailScreen.routeName,
    //                     arguments: product.id);
    //               },
    //               child: Image.network(
    //                 product.imageUrl,
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //             footer: GridTileBar(
    //               backgroundColor: Colors.black87,
    //               leading: IconButton(
    //                   onPressed: () {
    //                     product.toggleFavoriteStatus();
    //                   },
    //                   icon: Icon(
    //                     product.isFavorite
    //                         ? Icons.favorite
    //                         : Icons.favorite_border,
    //                     color: Theme.of(context).accentColor,
    //                   )),
    //               trailing: IconButton(
    //                   color: Theme.of(context).accentColor,
    //                   onPressed: () {},
    //                   icon: Icon(Icons.shopping_cart)),
    //               title: Text(
    //                 product.title,
    //                 textAlign: TextAlign.center,
    //               ),
    //             ),
    //           ),
    //         ));

    /**using only Provider */
    // final product = Provider.of<Product>(context, listen: true);

    // return ClipRRect(
    //   borderRadius: BorderRadius.circular(10),
    //   child: GridTile(
    //     child: GestureDetector(
    //       onTap: () {
    //         // Navigator.of(context).push(MaterialPageRoute(
    //         //     builder: (ctx) => ProductDetailScreen(title)));
    //         Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
    //             arguments: product.id);
    //       },
    //       child: Image.network(
    //         product.imageUrl,
    //         fit: BoxFit.cover,
    //       ),
    //     ),
    //     footer: GridTileBar(
    //       backgroundColor: Colors.black87,
    //       leading: IconButton(
    //           onPressed: () {
    //             product.toggleFavoriteStatus();
    //           },
    //           icon: Icon(
    //             product.isFavorite ? Icons.favorite : Icons.favorite_border,
    //             color: Theme.of(context).accentColor,
    //           )),
    //       trailing: IconButton(
    //           color: Theme.of(context).accentColor,
    //           onPressed: () {},
    //           icon: Icon(Icons.shopping_cart)),
    //       title: Text(
    //         product.title,
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   ),
    // );
  }
}
