import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:algorand_evoting/modules/home/repository/home_repository.dart';
import 'package:algorand_evoting/modules/modules.dart';

import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/modules/voting_creation/voting_creation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
              create: (context) =>
                  HomeBloc(context.read<AccountBloc>(), HomeRepository())
                    ..add(HomeStarted()),
              child: HomePage(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => context.read<HomeBloc>().add(
                  HomeStarted(),
                ),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: Colors.red,
            onPressed: () async {
              final result = await showOkCancelAlertDialog(
                context: context,
                title: 'Clear account',
                message:
                    'This will remove your existing account. Make sure you backed up the passphrase before continuing or you will lose your account.',
              );
              if (result == OkCancelResult.ok) {
                context.read<AccountBloc>().add(
                      AccountDeleteRequested(),
                    );
              }
            },
          ),
        ],
      ),
      body: state.loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildList(state: state),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.plus_one_rounded),
        onPressed: () async {
          bool success =
              await Navigator.of(context).push(VotingCreationPage.route());
          if (success) {
            // ! Need this because of indexer per second reuqests...
            await Future.delayed(const Duration(seconds: 1));
            context.read<HomeBloc>().add(
                  HomeStarted(),
                );
          }
        },
      ),
    );
  }
}

class _buildList extends StatelessWidget {
  const _buildList({
    Key? key,
    required this.state,
  }) : super(key: key);

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state.votings.length > 0) {
      return ListView.builder(
        itemCount: state.votings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(state.votings[index].title),
            subtitle: Text(state.votings[index].description ?? ''),
          );
        },
      );
    } else {
      return Center(
        child: Text('No votings available or server offline'),
      );
    }
  }
}
