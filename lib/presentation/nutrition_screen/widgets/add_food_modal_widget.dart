import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/app_export.dart';
import '../../../services/nutrition_service.dart';
import './barcode_scanner_page.dart';
import './nutrition_search_widget.dart';

// Se o NutritionSearchWidget estiver em outro path, ajuste o import:

class AddFoodModalWidget extends StatefulWidget {
  final String mealType;
  final VoidCallback onFoodAdded;

  const AddFoodModalWidget({
    Key? key,
    required this.mealType,
    required this.onFoodAdded,
  }) : super(key: key);

  @override
  State<AddFoodModalWidget> createState() => _AddFoodModalWidgetState();
}

class _AddFoodModalWidgetState extends State<AddFoodModalWidget> {
  List<Map<String, dynamic>> _recentFoods = [];
  bool _isLoading = true;

  final _imagePicker = ImagePicker();
  stt.SpeechToText? _speech;

  @override
  void initState() {
    super.initState();
    _loadRecentFoods();
  }

  Future<void> _loadRecentFoods() async {
    try {
      setState(() => _isLoading = true);
      final foods = await NutritionService.instance.searchFoodItems(
        verifiedOnly: true,
        limit: 10,
      );
      setState(() {
        _recentFoods = foods;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
    }
  }

  // ============== AÇÕES ==============

  // 1) Buscar alimento (abre o widget de busca e, ao selecionar, pede porção e adiciona)
  void _openSearch({String? hint}) {
    if (hint != null && hint.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sugestão de busca: "$hint"'),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
      ));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => NutritionSearchWidget(
        onFoodSelected: (foodItem) {
          Navigator.pop(context);
          _showPortionSelector(foodItem);
        },
      ),
    );
  }

  // 2) Scanner de código de barras
  void _scanBarcode() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (code == null) return;

    // Fecha o modal atual devolvendo o EAN para a tela que abriu
    Navigator.pop(context, code);
  }

  // 3) Foto (câmera/galeria) → por ora direciona para a busca
  Future<void> _useCamera() async {
    final source = await _askPhotoSource();
    if (source == null) return;

    final XFile? file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null) return;

    // TODO: plugar OCR/IA aqui e sugerir alimento automaticamente.
    // Por enquanto, direciona para a busca.
    _openSearch(hint: 'foto do rótulo/prato');
  }

  Future<ImageSource?> _askPhotoSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _photoAction('Tirar foto', 'photo_camera',
                  () => Navigator.pop(context, ImageSource.camera)),
              SizedBox(height: 1.2.h),
              _photoAction('Escolher da galeria', 'image',
                  () => Navigator.pop(context, ImageSource.gallery)),
              SizedBox(height: 1.2.h),
              _photoAction(
                  'Cancelar', 'close', () => Navigator.pop(context, null),
                  isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoAction(String label, String icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Row(
          children: [
            CustomIconWidget(
                iconName: icon, color: AppTheme.accentGold, size: 6.w),
            SizedBox(width: 3.w),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: isDestructive ? AppTheme.errorRed : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4) Voz → transcreve e abre busca
  Future<void> _useVoiceInput() async {
    _speech ??= stt.SpeechToText();
    final ok = await _speech!.initialize(
      onStatus: (_) {},
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro no microfone: ${e.errorMsg}'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ));
      },
    );
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Reconhecimento de voz indisponível'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    String spoken = '';
    await _speech!.listen(
      localeId: 'pt_BR',
      onResult: (res) => spoken = res.recognizedWords,
    );
    await Future.delayed(const Duration(seconds: 3));
    await _speech!.stop();

    if (spoken.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não entendi. Tente novamente.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    _openSearch(hint: spoken);
  }

  // ============== UI ==============

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.only(left: 38.w, bottom: 3.h),
              decoration: BoxDecoration(
                color: AppTheme.dividerGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Adicionar ${_formatMealType(widget.mealType)}',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Buscar comida',
                    'search',
                    AppTheme.accentGold,
                    _openSearch,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildActionButton(
                    'Escanear código de barras',
                    'qr_code_scanner',
                    AppTheme.successGreen,
                    _scanBarcode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Câmera',
                    'camera_alt',
                    AppTheme.errorRed,
                    _useCamera,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildActionButton(
                    'Voz',
                    'mic',
                    Colors.purple,
                    _useVoiceInput,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Comidas recentes',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.accentGold))
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: _recentFoods.length,
                      separatorBuilder: (_, __) => SizedBox(height: 1.h),
                      itemBuilder: (context, index) {
                        final food = _recentFoods[index];
                        return _buildRecentFoodItem(food);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, String icon, Color color, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 8.w),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFoodItem(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _showPortionSelector(food),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: 'restaurant',
                color: AppTheme.accentGold,
                size: 4.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'] ?? 'Unknown Food',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (food['brand'] != null)
                    Text(
                      food['brand'],
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${food['calories_per_100g']?.toInt() ?? 0} cal',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'add_circle_outline',
              color: AppTheme.textSecondary,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMealType(String mealType) {
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  // ====== Porção + adicionar no banco (reaproveita NutritionService) ======
  void _showPortionSelector(Map<String, dynamic> foodItem) {
    double quantity = 100;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(left: 38.w, bottom: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.dividerGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Definir porção',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 2.h),
              Text(foodItem['name'] ?? 'Alimento',
                  style: AppTheme.darkTheme.textTheme.titleMedium
                      ?.copyWith(color: AppTheme.textSecondary)),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Text('Quantidade (gramas):',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  const Spacer(),
                  Text('${quantity.round()}g',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 2.h),
              Slider(
                value: quantity,
                min: 10,
                max: 500,
                divisions: 49,
                activeColor: AppTheme.accentGold,
                inactiveColor: AppTheme.dividerGray,
                onChanged: (v) => setModalState(() => quantity = v),
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final meal = await NutritionService.instance.createMeal(
                      mealType: widget.mealType,
                      mealDate: DateTime.now(), // ou dê opção de data
                    );

                    await NutritionService.instance.addFoodToMeal(
                      mealId: meal['id'],
                      foodItemId: foodItem['id'],
                      quantityGrams: quantity,
                    );

                    if (mounted) Navigator.pop(context); // fecha porção
                    if (mounted) Navigator.pop(context); // fecha modal de ações
                    widget.onFoodAdded();

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Comida adicionada com sucesso!'),
                      backgroundColor: AppTheme.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Falha ao adicionar comida'),
                      backgroundColor: AppTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryBlack,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: SizedBox(
                  width: double.infinity,
                  child: Text('Adicionar comida',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.sp)),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== Tela de Scanner simples ==========
class _BarcodeScannerScreen extends StatefulWidget {
  final void Function(String code) onCode;
  const _BarcodeScannerScreen({Key? key, required this.onCode})
      : super(key: key);

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        title: const Text('Escanear código'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;
              final code = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.rawValue
                  : null;
              if (code != null && code.isNotEmpty) {
                _handled = true;
                widget.onCode(code);
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Aponte para o código de barras/QR do alimento',
                style: AppTheme.darkTheme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
