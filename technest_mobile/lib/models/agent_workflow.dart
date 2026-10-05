class AgentWorkflow {
  final String workflowId;
  final String status;
  final String objective;
  final List<AgentPlanStep> plan;
  final String chatResponse;
  final bool readyToBuild;
  final AgentBuild? build;
  final AgentValidation? validation;
  final List<String> errors;
  final String message;

  AgentWorkflow({
    required this.workflowId,
    required this.status,
    required this.objective,
    required this.plan,
    required this.chatResponse,
    required this.readyToBuild,
    required this.build,
    required this.validation,
    required this.errors,
    required this.message,
  });

  factory AgentWorkflow.fromJson(Map<String, dynamic> json) {
    return AgentWorkflow(
      workflowId: json['workflowId'] ?? '',
      status: json['status'] ?? '',
      objective: json['objective'] ?? '',
      plan: (json['plan'] as List<dynamic>? ?? [])
          .map(
            (item) => AgentPlanStep.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      chatResponse: json['chatResponse'] ?? '',
      readyToBuild: json['readyToBuild'] ?? false,
      build: json['build'] != null
          ? AgentBuild.fromJson(Map<String, dynamic>.from(json['build']))
          : null,
      validation: json['validation'] != null
          ? AgentValidation.fromJson(
              Map<String, dynamic>.from(json['validation']),
            )
          : null,
      errors: (json['errors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class AgentPlanStep {
  final int step;
  final String agent;
  final String task;

  AgentPlanStep({required this.step, required this.agent, required this.task});

  factory AgentPlanStep.fromJson(Map<String, dynamic> json) {
    return AgentPlanStep(
      step: json['step'] ?? 0,
      agent: json['agent'] ?? '',
      task: json['task'] ?? '',
    );
  }
}

class AgentBuild {
  final List<AgentProduct> products;
  final double totalAmount;
  final String explanation;

  AgentBuild({
    required this.products,
    required this.totalAmount,
    required this.explanation,
  });

  factory AgentBuild.fromJson(Map<String, dynamic> json) {
    return AgentBuild(
      products: (json['products'] as List<dynamic>? ?? [])
          .map((item) => AgentProduct.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      totalAmount: _toDouble(json['totalAmount']),
      explanation: json['explanation'] ?? '',
    );
  }
}

class AgentProduct {
  final int productId;
  final String name;
  final String category;
  final String brand;
  final double unitPrice;
  final String reason;

  AgentProduct({
    required this.productId,
    required this.name,
    required this.category,
    required this.brand,
    required this.unitPrice,
    required this.reason,
  });

  factory AgentProduct.fromJson(Map<String, dynamic> json) {
    return AgentProduct(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      unitPrice: _toDouble(json['unitPrice']),
      reason: json['reason'] ?? '',
    );
  }
}

class AgentValidation {
  final bool isValid;
  final List<AgentValidationIssue> issues;
  final List<AgentValidationIssue> errors;
  final List<AgentValidationIssue> warnings;
  final double totalAmount;
  final double? budget;

  AgentValidation({
    required this.isValid,
    required this.issues,
    required this.errors,
    required this.warnings,
    required this.totalAmount,
    required this.budget,
  });

  factory AgentValidation.fromJson(Map<String, dynamic> json) {
    return AgentValidation(
      isValid: json['isValid'] ?? false,
      issues: (json['issues'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AgentValidationIssue.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      errors: (json['errors'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AgentValidationIssue.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AgentValidationIssue.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      totalAmount: _toDouble(json['totalAmount']),
      budget: json['budget'] == null ? null : _toDouble(json['budget']),
    );
  }
}

class AgentValidationIssue {
  final String rule;
  final String severity;
  final String message;

  AgentValidationIssue({
    required this.rule,
    required this.severity,
    required this.message,
  });

  factory AgentValidationIssue.fromJson(Map<String, dynamic> json) {
    return AgentValidationIssue(
      rule: json['rule'] ?? '',
      severity: json['severity'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}
