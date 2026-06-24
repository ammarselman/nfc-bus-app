import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      // خلفية خفيفة متدرجة (مظهر فقط)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary.withOpacity(.08), cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // شعار/أيقونة
                          Center(
                            child: CircleAvatar(
                                radius: 50,
                                backgroundColor: cs.primary.withOpacity(.12),
                                child: Image.asset("lib/assets/bus.png")),
                          ),
                          const SizedBox(height: 16),

                          // عنوان + وصف
                          Center(
                            child: Text(
                              'Welcome back',
                              style: text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              'Log in to continue to your dashboard',
                              style: text.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: controller.emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'name@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: cs.surfaceVariant.withOpacity(.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: controller.emailValidator,
                            autofillHints: const [AutofillHints.username],
                          ),
                          const SizedBox(height: 14),

                          // Password
                          Obx(() => TextFormField(
                                controller: controller.passCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: controller.showPass.value
                                        ? 'Hide password'
                                        : 'Show password',
                                    onPressed: () =>
                                        controller.showPass.toggle(),
                                    icon: Icon(controller.showPass.value
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                  filled: true,
                                  fillColor: cs.surfaceVariant.withOpacity(.35),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: !controller.showPass.value,
                                validator: controller.passValidator,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => controller.login(),
                              )),
                          const SizedBox(height: 16),

                          // زر الدخول
                          Obx(() => FilledButton(
                                onPressed: controller.loading.value
                                    ? null
                                    : controller.login,
                                style: FilledButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  child: controller.loading.value
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Login'),
                                ),
                              )),

                          const SizedBox(height: 12),

                          // تذييل صغير (مظهر فقط)
                          Center(
                            child: Text(
                              'By continuing you agree to our Terms & Privacy',
                              style: text.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
