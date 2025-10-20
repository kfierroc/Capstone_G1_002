import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'person_card.dart';
import 'pet_card.dart';

/// Vista de pestañas para ocupantes del domicilio
class OccupantsTabView extends StatefulWidget {
  final List<Map<String, dynamic>> people;
  final List<Map<String, dynamic>> pets;

  const OccupantsTabView({
    super.key,
    required this.people,
    required this.pets,
  });

  @override
  State<OccupantsTabView> createState() => _OccupantsTabViewState();
}

class _OccupantsTabViewState extends State<OccupantsTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMd),
      decoration: AppThemeDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ocupantes del Domicilio',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  'Información detallada de personas y mascotas en la residencia',
                  style: AppTextStyles.subtitleSecondary,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.border),
                bottom: BorderSide(color: AppTheme.border),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.secondary,
              unselectedLabelColor: AppTheme.textTertiary,
              indicatorColor: AppTheme.secondary,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Personas (${widget.people.length})'),
                Tab(text: 'Mascotas (${widget.pets.length})'),
              ],
            ),
          ),
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Personas
                ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMd),
                  itemCount: widget.people.length,
                  itemBuilder: (context, index) {
                    return PersonCard(person: widget.people[index]);
                  },
                ),
                // Tab Mascotas
                ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMd),
                  itemCount: widget.pets.length,
                  itemBuilder: (context, index) {
                    return PetCard(pet: widget.pets[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
