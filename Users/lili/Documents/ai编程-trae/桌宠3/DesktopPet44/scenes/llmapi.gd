extends Node
class_name  AI

# 当LLM API请求完成时发出的信号
signal  request_finished
@onready var http_request: HTTPRequest = $HTTPRequest

# 存储API返回的响应内容
var output: String
# 存储对话历史记录
var history: Array
# 发送给API的历史记录条数限制
var history_count: int = 3

# 初始化节点时连接HTTP请求完成信号
func _ready() -> void:
	http_request.request_completed.connect(on_request_completed)

# 调用LLM API的主要函数
# 更换API时需要修改：
# 1. API的URL地址
# 2. 认证方式（Bearer Token、API Key等）
# 3. 请求体格式（model名称、temperature等参数）
# 4. 响应格式的解析方式
func call_aliyun(prompt):
	# 构造用户消息
	var new_message = {"role": "user", "content": prompt} 
	# 系统预设消息，定义AI助手的角色和行为
	var sys_message = {"role": "system", "content": "你是一个名叫小狐狸的桌面宠物程序，你的功能是陪伴用户和解答各学科的知识，你的回答必须准确而且风趣，而且字数不超过200个字"}
	# 将新消息添加到历史记录
	history.append(new_message)
	# 构造完整的消息数组，包含系统消息和最近的对话历史
	var messages = [sys_message]
	messages.append_array(history.slice(-history_count))

	# API配置部分 - 更换API时需要修改
	# 注意：此API密钥仅用于开发环境，生产环境应该使用更安全的方式存储
	var api_key = "d74073bc-4bc6-4ea7-99df-d9f23d86e420"
	# 请求头配置，根据API要求设置认证方式和内容类型
	var header = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
	# 请求体配置，包含模型选择和消息内容
	var body = JSON.stringify({
		"model": "deepseek-r1-250120",
		"messages" : messages,
		"stream" : false
	})
	# API端点URL
	var url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
	# 设置请求超时为60秒
	http_request.timeout = 60
	# 发送HTTP POST请求
	var request_result = http_request.request(url,
									header,
									HTTPClient.METHOD_POST,
									body)

	
# HTTP请求完成后的回调函数
# 更换API时需要修改：
# 1. 响应JSON的解析方式
# 2. 响应内容的提取路径
# 3. 历史记录的存储格式
func on_request_completed(result, response_code, headers, body):
	# 解析API返回的JSON响应
	var response = JSON.parse_string(body.get_string_from_utf8())
	# 从响应中提取AI的回复内容
	output = response['choices'][0].message.content
	# 将AI的回复添加到对话历史
	history.append({"role": "assistant", "content":output})
	# 发出请求完成信号
	request_finished.emit(output)
