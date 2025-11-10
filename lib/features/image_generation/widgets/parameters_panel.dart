import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/image_generation_provider.dart';

class ParametersPanel extends StatefulWidget {
  final bool isWeb;

  const ParametersPanel({super.key, this.isWeb = false});

  @override
  State<ParametersPanel> createState() => _ParametersPanelState();
}

class _ParametersPanelState extends State<ParametersPanel> {
  final List<String> _models = [
    'Stable Diffusion XL',
    'Stable Diffusion 2.1',
    'DALL-E 3',
    'Midjourney v6',
    'Kandinsky 2.2',
  ];

  final List<String> _sizes = [
    '512x512',
    '768x768',
    '1024x1024',
    '1024x1792',
    '1792x1024',
  ];

  final List<String> _samplers = [
    'DPMSolver',
    'Euler A',
    'DDIM',
    'PLMS',
    'DPM++ 2M',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageGenerationProvider>(context);
    final parameters = provider.parameters;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.tune, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Generation Parameters',
                  style: TextStyle(
                    fontSize: widget.isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Parameters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Model
                  _buildParameterRow(
                    'Model',
                    _buildDropdown(
                      value: _models[0],
                      items: _models,
                      onChanged: (value) {
                        provider.updateParameters(
                          parameters.copyWith(model: value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Size
                  _buildParameterRow(
                    'Size',
                    _buildDropdown(
                      value: parameters.size,
                      items: _sizes,
                      onChanged: (value) {
                        provider.updateParameters(
                          parameters.copyWith(size: value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Steps
                  _buildParameterRow(
                    'Steps',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: parameters.steps.toDouble(),
                          min: 10,
                          max: 50,
                          divisions: 8,
                          label: parameters.steps.toString(),
                          onChanged: (value) {
                            provider.updateParameters(
                              parameters.copyWith(steps: value.toInt()),
                            );
                          },
                        ),
                        Text(
                          '${parameters.steps} steps',
                          style: TextStyle(
                            fontSize: widget.isWeb ? 12 : 10,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Guidance Scale
                  _buildParameterRow(
                    'Guidance Scale',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: parameters.guidanceScale,
                          min: 1.0,
                          max: 20.0,
                          divisions: 38,
                          label: parameters.guidanceScale.toStringAsFixed(1),
                          onChanged: (value) {
                            provider.updateParameters(
                              parameters.copyWith(guidanceScale: value),
                            );
                          },
                        ),
                        Text(
                          parameters.guidanceScale.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: widget.isWeb ? 12 : 10,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sampler
                  _buildParameterRow(
                    'Sampler',
                    _buildDropdown(
                      value: parameters.sampler,
                      items: _samplers,
                      onChanged: (value) {
                        provider.updateParameters(
                          parameters.copyWith(sampler: value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Seed
                  _buildParameterRow(
                    'Seed',
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Random',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final seed = int.tryParse(value);
                        if (seed != null) {
                          provider.updateParameters(
                            parameters.copyWith(seed: seed),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String label, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: widget.isWeb ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        control,
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  item,
                  style: TextStyle(fontSize: widget.isWeb ? 14 : 12),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
