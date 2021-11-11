import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(GraphQLSubscriptionDemo());
}

class GraphQLSubscriptionDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      'http://137.184.33.31:5847/graphql',
    );

    final WebSocketLink websocketLink = WebSocketLink(
      'ws://test.qiubapp.com:5847/subscriptions',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink.concat(websocketLink),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text("Graphql Subscription Demo"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Counter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Counter extends StatelessWidget {
  static final subscription = gql('''subscription{
  escucharNotificaciones(code: "9520"){
    typo
    mensaje
    persona{
      idPersona
      imagen
    }
    creado
    eventoId
  }
}''');

  @override
  Widget build(BuildContext context) {
    return Subscription(
        options: SubscriptionOptions(
          document: subscription,
        ),
        builder: (result) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
          // ResultAccumulator is a provided helper widget for collating subscription results.
          // careful though! It is stateful and will discard your results if the state is disposed
          return ResultAccumulator.appendUniqueEntries(
              latest: result.data,
              builder: (context, {results}) => ListView.builder(
                    itemCount: result.data!.length,
                    itemBuilder: (context, index) =>
                        Text(result.data.toString()),
                  ));
        });
  }
}
