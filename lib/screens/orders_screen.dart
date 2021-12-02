import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // var _isLoading = false;

/**NOTE - since using FutureBuilder to manage loading state,
 *  don't need this widget to be stateful.
 * 
 * But kept it staeful to handle a scenario where the widget's build method is called due to some other state change,,
 * resulting into fetchandSetOrders() method being called again which will make unncessary HTTP requests.
 * 
 * Products overview screen uses different approach.
 * */

  // @override
  // void initState() {
  /**If we use "listen: false" on provider, 
     * we can make Provider work in initState() without the Future.delayed hack */

  /**Following code can be optimised/simplified  by using FutureBuilder widget */
  // _isLoading = true;
  // Provider.of<Orders>(context, listen: false).fetchAndSetProducts().then((_) {
  //   setState(() {
  //     _isLoading = false;
  //   });
  // });
  //   super.initState();
  // }

  // @override
  // void initState() {
  //   Future.delayed(Duration.zero).then((_) async {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     await Provider.of<Orders>(context, listen: false).fetchAndSetProducts();
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /**If used with FutureBuilder, will result into infinite build method loop,
     * Hence moved from here and added Consumer
     */
    //final ordersData = Provider.of<Orders>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Your Orders"),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          //    future:
//              Provider.of<Orders>(context, listen: false).fetchAndSetProducts(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                //Error handling
                return Center(
                  child: Text("An error occurred."),
                );
              } else {
                return Consumer<Orders>(
                    builder: (ctx, ordersData, child) => ListView.builder(
                          itemBuilder: (ctx, i) =>
                              OrderItem(ordersData.orders[i]),
                          itemCount: ordersData.orders.length,
                        ));
              }
            }
          },
        )

/**this will need initState(code. )Start */
        //  body:
        //     _isLoading
        //         ? Center(
        //             child: CircularProgressIndicator(),
        //           )
        //         : ListView.builder(
        //             itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
        //             itemCount: ordersData.orders.length,
        //           ),
/**end */

        );
  }
}
