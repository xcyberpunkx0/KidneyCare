import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ask/presentation/pages/ask_page.dart';
import '../../features/capture/presentation/pages/batch_import_page.dart';
import '../../features/capture/presentation/pages/capture_flow_page.dart';
import '../../features/claims/presentation/pages/claim_detail_page.dart';
import '../../features/claims/presentation/pages/claim_edit_page.dart';
import '../../features/claims/presentation/pages/claims_page.dart';
import '../../features/claims/presentation/pages/policy_edit_page.dart';
import '../../features/dialysis/presentation/pages/dialysis_page.dart';
import '../../features/dialysis/presentation/pages/log_session_page.dart';
import '../../features/documents/presentation/pages/document_viewer_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../features/labs/presentation/pages/labs_page.dart';
import '../../features/labs/presentation/pages/manual_lab_entry_page.dart';
import '../../features/medications/presentation/pages/add_medication_page.dart';
import '../../features/medications/presentation/pages/medications_page.dart';
import '../../features/patient/presentation/pages/emergency_card_page.dart';
import '../../features/patient/presentation/pages/patient_edit_page.dart';
import '../../features/patient/presentation/pages/patient_setup_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/symptoms/presentation/pages/symptom_log_page.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import 'app_shell.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Where the app opens: [AppRoutes.onboarding] until a patient exists.
/// Set once in main() after the startup check, before the app builds.
class StartupLocationController extends Notifier<String> {
  @override
  String build() => AppRoutes.home;

  void set(String location) => state = location;
}

final initialLocationProvider =
    NotifierProvider<StartupLocationController, String>(
      StartupLocationController.new,
    );

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ref.watch(initialLocationProvider),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.homeName,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'documents',
                    name: AppRoutes.documentsName,
                    builder: (context, state) => DocumentsPage(
                      initialFilter: state.uri.queryParameters['type'],
                    ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'documentViewer',
                        builder: (context, state) => DocumentViewerPage(
                          documentId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'timeline',
                    name: AppRoutes.timelineName,
                    builder: (context, state) => const TimelinePage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        path: 'patient',
                        name: 'patientEdit',
                        builder: (context, state) => const PatientEditPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.labs,
                name: AppRoutes.labsName,
                builder: (context, state) => LabsPage(
                  initialMetricCode: state.uri.queryParameters['metric'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dialysis,
                name: 'dialysis',
                builder: (context, state) => const DialysisPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.medications,
                name: AppRoutes.medicationsName,
                builder: (context, state) => const MedicationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ask,
                name: AppRoutes.askName,
                builder: (context, state) => const AskPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PatientSetupPage(),
      ),
      GoRoute(
        path: '/lab-entry',
        name: 'labEntry',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManualLabEntryPage(),
      ),
      GoRoute(
        path: '/session-log',
        name: 'sessionLog',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            LogSessionPage(sessionId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/symptom-log',
        name: 'symptomLog',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SymptomLogPage(),
      ),
      GoRoute(
        path: '/emergency-card',
        name: 'emergencyCard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmergencyCardPage(),
      ),
      GoRoute(
        path: '/policy',
        name: 'policyEdit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PolicyEditPage(),
      ),
      GoRoute(
        path: '/medication-entry',
        name: 'addMedication',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            AddMedicationPage(medicationId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.capture,
        name: AppRoutes.captureName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CaptureFlowPage(),
      ),
      GoRoute(
        path: AppRoutes.import,
        name: AppRoutes.importName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BatchImportPage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: AppRoutes.searchName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.claims,
        name: AppRoutes.claimsName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClaimsPage(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'claimEdit',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) =>
                ClaimEditPage(claimId: state.uri.queryParameters['id']),
          ),
          GoRoute(
            path: ':id',
            name: 'claimDetail',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) =>
                ClaimDetailPage(claimId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
