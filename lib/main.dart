import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(GraphQLSubscriptionDemo());
}

class GraphQLSubscriptionDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      uri: 'http://test.qiubapp.com:5847/graphql',
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
              children: [
                IncrementButton(),
                SizedBox(height: 3, child: Container(color: Colors.green)),
                Counter()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IncrementButton extends StatelessWidget {
  static String emit = '''
  mutation{
    emitirNotificacion(input:{
      idUsuario:"9520"
      nombre:"Alejandro notifica44"
      typo:COMMENT
      imagen:"sandakjsdnkjandsj"
      idPersona:"123"
      mensaje:["El usuario","alejandro","le gusta","su comentario."]
    }){
      topic
      partition
      offset
      timestamp
    }
  }''';

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        documentNode: gql(emit),
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return Center(
          child: RaisedButton.icon(
            onPressed: () {
              runMutation({});
            },
            icon: Icon(Icons.plus_one),
            label: Text(""),
          ),
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
      null,
      subscription,
      builder: ({
        bool loading,
        dynamic payload,
        dynamic error,
      }) {
        if (payload != null && payload.isNotEmpty) {
          return Text(payload.toString());
        } else {
          return Text("Paso sin datos");
        }
      },
    );
  }
}
