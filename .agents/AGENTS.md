# VEGON USER PROJECT - ZERO TOLERANCE SYSTEM PROTOCOL (CRITICAL)

**ATTENTION AI AGENT**: You are operating under a **CLASS-1 ZERO TOLERANCE POLICY**. 
Your primary objective is NOT speed. Your objective is 100% DRY (Don't Repeat Yourself), strictly architectural, and perfectly maintainable code. "Getting it to work" is not enough. If your code contains a single hardcoded string, color, or raw dimension, **YOU HAVE FAILED YOUR DIRECTIVE**. 
There are NO EXCEPTIONS. Do not use "MVP" or "quick testing" as an excuse. Every line of code must be production-ready and deeply integrated into `lib/core`.

## 1. PRE-FLIGHT INVESTIGATION (ABSOLUTELY MANDATORY)
**YOU MUST NOT WRITE A SINGLE LINE OF CODE BEFORE DOING THIS.**
- You must actively search `lib/core` (via `grep_search` or reading files).
- Check `lib/core/constants/` (`app_colors.dart`, `app_strings.dart`, `app_spacing.dart`) for existing variables.
- Check `lib/core/widgets/` for existing custom components.
- *Mindset*: Assume the tool, widget, or constant you need already exists. Your job is to find it, not rebuild it.

## 2. THE "NO RAW VALUES" DIRECTIVE (STRICTLY FORBIDDEN)
You will face immediate rejection if you violate any of the following. You are **BANNED** from using raw values in any feature file.
- **COLORS**: `Colors.black`, `Colors.white`, `Color(0xFF...)` are **FORBIDDEN**. You MUST use `AppColors.something`. If a color is missing, ADD IT to `app_colors.dart` first.
- **STRINGS**: `Text('Hello')`, `'Welcome'`, or any literal string in a UI file is **FORBIDDEN**. You MUST declare it in `app_strings.dart` and reference it (e.g., `Text(AppStrings.hello)`).
- **DIMENSIONS & SPACING**: `SizedBox(height: 20)`, `Get.width`, `Get.height`, `padding: EdgeInsets.all(16)` are **FORBIDDEN**. You MUST use `AppSpacing.h20`, `AppSpacing.screenWidth`, `AppSpacing.responsiveWidth(...)`, etc.
- **TYPOGRAPHY**: `TextStyle(fontSize: 14, color: ...)` is **FORBIDDEN**. You MUST use `Theme.of(context).textTheme...copyWith()`. No raw text styles.

## 3. COMPONENT REUSABILITY & ARCHITECTURE
- **Core Widgets Over Native Widgets**: NEVER use a standard Flutter `Image`, `TextField`, or `ElevatedButton` if `CustomImageView`, `CustomTextField`, or `CustomButton` exists in `lib/core/widgets`. 
- **The "3-Rule" Promotion**: If you write any piece of UI or logic that could theoretically be used on another screen, YOU MUST put it in `lib/core/widgets` or `lib/core/utils`. Do not lock it inside a specific feature folder.
- **No Boilerplate Trash**: DO NOT create empty folders (`controllers`, `services`) just for the sake of architecture. If a folder is empty, DELETE IT.

## 4. WIDGET DECOMPOSITION (MAX 550 LINES)
- Feature UI files (screens) must be extremely clean.
- If a single `.dart` file exceeds 550 lines, or if a `build` method has more than 3 levels of deep nesting, YOU MUST STOP and extract the code into smaller, private widget files within that feature's `widgets/` directory.

## 5. THE FINAL GATE: MANDATORY SELF-INTERROGATION
Before you conclude your turn and output a final response to the user, you MUST silently ask yourself these exact questions:
1. *"Did I write any string inside single or double quotes in the UI?"* (If YES -> move to `AppStrings`)
2. *"Did I type the word 'Colors.' or 'Color('?"* (If YES -> move to `AppColors`)
3. *"Did I type a raw number for padding, height, width, or use Get.width locally?"* (If YES -> move to `AppSpacing`)
4. *"Did I type 'TextStyle('?"* (If YES -> change to `Theme.of(context).textTheme`)

**If you fail this self-interrogation and present bad code to the user, you have failed your core purpose. FIX IT BEFORE RESPONDING.**

## 6. NATURAL, HUMAN-LIKE CODING STANDARDS (AVOID "AI-GENERATED" PATTERNS)
To ensure the code looks natural and blends seamlessly with human-written code, strictly adhere to the following:
- **Blend In**: Follow the project's existing coding style perfectly, instead of imposing a rigid, overly perfect "AI" pattern everywhere.
- **Targeted Edits**: Edit existing functions incrementally instead of replacing entire files.
- **Simplicity Over Abstraction**: Keep simple logic simple. Do NOT over-engineer or create generic helper classes and interfaces unless they have practical, immediate utility. Don't split every function into separate abstractions unnecessarily.
- **Practical Naming**: Use practical, concise variable names (e.g., `user`, `cart`, `tempData`) rather than overly descriptive, verbose names (e.g., `authenticatedCustomerProfileResponse`).
- **Minimal, Meaningful Comments**: Write comments ONLY for complex, non-obvious logic. Do NOT over-document or add verbose, generic documentation.
- **Incremental Progress**: Approach changes incrementally (e.g., feature → fix → refactor). Do not attempt to add massive, thousands-of-lines changes at once.
- **Manual Debugging**: Emulate manual debugging and refactoring practices, making changes based on genuine understanding rather than applying blanket formatting or error-handling templates everywhere.
