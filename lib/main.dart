import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(GraphQLSubscriptionDemo());
}

class GraphQLSubscriptionDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      uri: 'http://137.184.33.31:5847/graphql',
    );

    final WebSocketLink websocketLink = WebSocketLink(
      url: 'ws://test.qiubapp.com:5847/subscriptions',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
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
              children: [Counter(), ],
            ),
          ),
        ),
      ),
    );
  }
}

class IncrementButton extends StatelessWidget {
  static String incr = '''mutation{
  emitirNotificacion(input: {
    idUsuario:"7152",
    typo:FOLLOW,
    mensaje:"h",
    idPersona: "11",
    nombre:"jsjs",
    imagen:"sas"
  }){
    topic
    partition
    offset
    timestamp
  }
}
''';

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        documentNode: gql(incr),
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return Column(
          children: [
            Center(
              child: RaisedButton.icon(
                onPressed: () {
                  runMutation({});
                },
                icon: Icon(Icons.notification_add
                ),
                label: Text('Emitir'),
              ),
            ),
            Text(result.data.toString() ?? 'hola')
          ],
        );
      },
    );
  }
}

class Counter extends StatelessWidget {
  static String subscription = '''subscription{
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
}''';

  @override
  Widget build(BuildContext context) {
    return Subscription(
      "escucharNotificaciones",
      subscription,
      builder: ({
        bool loading,
        dynamic payload,
        dynamic error,
      }) {
        print(error);
        if (payload != null) {
          return Text(payload.toString());
        } else {
          return Text(error.toString());
        }
      },
    );
  }
}
