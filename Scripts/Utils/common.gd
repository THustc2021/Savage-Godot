class_name utils

# 加权随机选择函数
static func choice(values_array, probabilities_array):
	# 归一化处理
	var total_sum = 0.0
	for prob in probabilities_array:
		total_sum += prob
	var normalized_probabilities = []
	for prob in probabilities_array:
		normalized_probabilities.append(prob / total_sum)
	
	# 构建累计概率数组
	var cumulative_probabilities = []
	var cumulative_sum = 0.0
	
	# 构建累计概率数组
	for prob in normalized_probabilities:
		cumulative_sum += prob
		cumulative_probabilities.append(cumulative_sum)
	# 生成一个 0 到 1 之间的随机数
	var random_value = randf()
	
	# 根据随机数选择相应的值
	for i in range(len(cumulative_probabilities)):
		if random_value <= cumulative_probabilities[i]:
			return values_array[i]
	
	# 默认返回最后一个值（通常不会到达这里，除非有浮点精度问题）
	return values_array[-1]
