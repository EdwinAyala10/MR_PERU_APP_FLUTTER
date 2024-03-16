import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/agenda/presentation/providers/events_provider.dart';
import 'package:crm_app/features/agenda/presentation/widgets/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Calendario'),
        /*actions: [
          IconButton(onPressed: () {
            
          }, icon: const Icon(Icons.refresh))
        ],*/
      ),
      body: const _AgendaView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.push('/event/new');
        },
      ),
    );
  }
}

class _AgendaView extends ConsumerStatefulWidget {
  const _AgendaView();

  @override
  _AgendaViewState createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState {
  //late final ValueNotifier<List<EventMock>> _selectedEvents;
  //final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  late PageController _pageController;
  //DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    //_selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    ref.read(eventsProvider.notifier).onSelectedEvents(DateTime.now());
  }

  @override
  void dispose() {
    //_focusedDay.dispose();
    //_selectedEvents.dispose();
    super.dispose();
  }

  List<EventMock> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    //if (!isSameDay(eventState, selectedDay)) {
    /*setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });*/

    ref.read(eventsProvider.notifier).onChangeSelectedDay(selectedDay);
    ref.read(eventsProvider.notifier).onChangeFocusedDay(focusedDay);
    ref.read(eventsProvider.notifier).onSelectedEvents(selectedDay);
    //}
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return Center(
      child: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: ValueNotifier(eventsState.focusedDay),
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedDay: value,
                onRefresh: () {
                  ref.read(eventsProvider.notifier).loadNextPage();
                },
                onTodayButtonTap: () {
                  //setState(() => _focusedDay.value = DateTime.now());
                  ref
                      .read(eventsProvider.notifier)
                      .onChangeFocusedDay(DateTime.now());
                },
                onLeftArrowTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                onRightArrowTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              );
            },
          ),
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: ValueNotifier(eventsState.focusedDay).value,
            //focusedDay: _focusedDay.value,
            locale: 'es_ES',
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            selectedDayPredicate: (day) {
              return isSameDay(eventsState.selectedDay, day);
            },
            calendarFormat: CalendarFormat.week,
            //eventLoader: _getEventsForDay,
            eventLoader: (day) {
              return eventsState
                      .linkedEvents[DateTime(day.year, day.month, day.day)] ??
                  [];
            },
            onDaySelected: _onDaySelected,
            onCalendarCreated: (controller) => _pageController = controller,
            onPageChanged: (focusedDay) {
              //_focusedDay.value = focusedDay;
              ref
                  .read(eventsProvider.notifier)
                  .onChangeFocusedDay(focusedDay);
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12.0),
              ),
              markersMaxCount: 4,
              markerSize: 6,
              selectedDecoration: const BoxDecoration(
              color: Colors.blueGrey, // Cambia el color a tu gusto
              shape: BoxShape.circle,
            )
            ),
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              //valueListenable: _selectedEvents,
              valueListenable: ValueNotifier(eventsState.selectedEvents),
              builder: (context, value, _) {
                return value.length > 0
                    ? ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          Widget divider =
                              index != 0 ? const Divider() : const SizedBox.shrink();
                          final event = value[index];

                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  context.push('/event/${value[index].id}');
                                },
                                leading: Column(
                                  children: [
                                    Text(
                                        DateFormat('hh:mm a').format(value[
                                                        index]
                                                    .evntHoraInicioEvento !=
                                                null
                                            ? DateFormat('HH:mm:ss').parse(
                                                value[index]
                                                        .evntHoraInicioEvento ??
                                                    '')
                                            : DateTime.now()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        DateFormat('hh:mm a').format(value[index]
                                                    .evntHoraFinEvento !=
                                                null
                                            ? DateFormat('HH:mm:ss').parse(
                                                value[index]
                                                        .evntHoraInicioEvento ??
                                                    '')
                                            : DateTime.now()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.evntAsunto,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    Text('${event.evntNombreTipoGestion}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      )
                    : const Center(
                        child: Text('Sin eventos',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      );
              },
            ),
          ),
        ],
      ),
    );
    /*return DefaultTabController(
      length: 2, // Cambia este valor al número de pestañas que desees
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'POR MES'),
              Tab(text: 'POR DÍA'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMonthView(),
                _buildCalendarView(CalendarView.week),
              ],
            ),
          ),
        ],
      ),
    );*/
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onRefresh;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onRefresh,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
