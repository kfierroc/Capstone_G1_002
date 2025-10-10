import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ocupantes del Domicilio',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSizes.spaceSm),
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
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.secondary,
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
                  padding: const EdgeInsets.all(AppSizes.padding),
                  itemCount: widget.people.length,
                  itemBuilder: (context, index) {
                    return PersonCard(person: widget.people[index]);
                  },
                ),
                // Tab Mascotas
                ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.padding),
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
