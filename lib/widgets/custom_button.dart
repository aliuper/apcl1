import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height = 54,
    this.borderRadius = 14,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: double.infinity,
              height: widget.height,
              child: widget.isOutlined
                  ? _buildOutlinedButton(isEnabled)
                  : _buildFilledButton(isEnabled),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilledButton(bool isEnabled) {
    final bgColor = widget.backgroundColor ?? AppTheme.primaryColor;

    return ElevatedButton(
      onPressed: isEnabled ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? bgColor : AppTheme.cardColorLight,
        foregroundColor: widget.textColor ?? Colors.white,
        disabledBackgroundColor: AppTheme.cardColorLight,
        disabledForegroundColor: AppTheme.textHint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        elevation: isEnabled ? 4 : 0,
        shadowColor: bgColor.withOpacity(0.4),
      ),
      child: _buildContent(isEnabled),
    );
  }

  Widget _buildOutlinedButton(bool isEnabled) {
    final color = widget.backgroundColor ?? AppTheme.primaryColor;

    return OutlinedButton(
      onPressed: isEnabled ? widget.onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: isEnabled ? color : AppTheme.textHint,
        side: BorderSide(
          color: isEnabled ? color : AppTheme.cardColorLight,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
      child: _buildContent(isEnabled),
    );
  }

  Widget _buildContent(bool isEnabled) {
    if (widget.isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isOutlined
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Yükleniyor...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: widget.isOutlined
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 22,
            color: isEnabled
                ? (widget.isOutlined
                    ? widget.backgroundColor ?? AppTheme.primaryColor
                    : widget.textColor ?? Colors.white)
                : AppTheme.textHint,
          ),
          const SizedBox(width: 10),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isEnabled
                ? (widget.isOutlined
                    ? widget.backgroundColor ?? AppTheme.primaryColor
                    : widget.textColor ?? Colors.white)
                : AppTheme.textHint,
          ),
        ),
      ],
    );
  }
}

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final List<Color> gradientColors;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradientColors = const [AppTheme.primaryColor, AppTheme.secondaryColor],
    this.height = 54,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isEnabled ? null : AppTheme.cardColorLight,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: widget.gradientColors.first.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Yükleniyor...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 22,
                              color: isEnabled ? Colors.white : AppTheme.textHint,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isEnabled ? Colors.white : AppTheme.textHint,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
