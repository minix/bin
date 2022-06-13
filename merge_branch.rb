#!/usr/local/opt/ruby/bin/ruby
#
require 'net/http'
require 'json'
require 'uri'
require 'logger'
require 'cgi'

logger = Logger.new('logs/deploy_run.log')
logger.level = Logger::INFO

logger.formatter = proc do |level, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    JSON.dump(date: "#{date_format}", level:"#{level.ljust(5)}", message: msg) + "\n"
end

jenkins_host = 'http://xx.xxx.xxx.x:3000/job/'
jenkins_module = CGI.escape("QA_后端应用")
jenkins_build = '/build?delay=0sec'
jenkins_last_build = '/lastBuild/api/json'

jenkins_user = "gree"
jenkins_token = "11c7b5fe6af8a4dcafa7734fesrde868ba8e9"

$project_id = 275

def get_response(url, auth_name, auth_token)
  return_data = {"code" => "", "body" => ""}
  uri = URI.parse(url)

  req = Net::HTTP::Get.new(uri)
  req.basic_auth(auth_name, auth_token)

  resp = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end

  return_data["code"] = resp.code
  return_data["body"] = resp.body

  return return_data
end

def post_response(url, auth_name, auth_token, post_data, req_content_type="application/x-www-form-urlencoded")
  return_data = {"code" => "", "body" => ""}
  uri = URI.parse(url)
  req = Net::HTTP::Post.new(uri)
  req.content_type = req_content_type
  req.basic_auth(auth_name, auth_token)
  req.body = post_data

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  resp = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(req)
  end

  return_data["code"] = resp.code
  return_data["body"] = resp.body
  return return_data
end

module_list = []
n = 0

##################   gitlab合并分支 ###########################
#创建合并uri POST /projects/:id/merge_requests
#合并uri PUT /projects/:id/merge_requests/:merge_request_iid/merge

def return_data(resp)
    rdata = Hash.new
    rdata["code"] = resp.code
    rdata["data"] = resp.body

    return rdata
end

def http_method(uri, method, iid="", body="")
    new_uri = URI.parse(uri)
    send_body = ""
    case method
    when "get"
        req = Net::HTTP::Get.new(new_uri)
    when "post"
        req = Net::HTTP::Post.new(new_uri)
        send_body = URI.encode_www_form(JSON.parse(body))
    when "put"
        req = Net::HTTP::Put.new(new_uri)
    else
        "Error: not found the method (#{method})"
        exit
    end
    req["PRIVATE-TOKEN"] = "MNwzLpsvSx4gWCzwGYpz"
    resp = Net::HTTP.start(new_uri.hostname, new_uri.port) do |http|
        http.request(req, send_body)
    end
    return return_data(resp)
end

#合并分支
def merge(iid)
#    logger.info("要合并的iid是#{iid}")
    resp = http_method("http://xx.x.xxx.xx:8000/api/v4/projects/#{$project_id}/merge_requests/#{iid}/merge", "put", iid)
#    resp_status = resp["code"].to_i
#    if resp_status != 200
#        logger.info("合并失败,原因是: #{resp["data"]}")
#    else
#        logger.info("#{iid}合并完成")
#    end
    return resp
end

#检查提交记录，如果没有就关闭合并请求
#如果不检查，在合并的时候会报错
def check_commit(iid)
#logger.info("检查提交记录")
    status = Hash.new()
    status["code"] = 200
    status["data"] = ""
    commit = http_method("http://xx.x.xxx.xx:8000/api/v4/projects/#{$project_id}/merge_requests/#{iid}/commits", "get")
    commit_record = JSON.parse(commit["data"])
    if commit_record.empty?
        status["code"] = 499
        status["data"] = "提交记录为空，关闭合并请求"
        haha = http_method("http://xx.x.xxx.xx:8000/api/v4/projects/#{$project_id}/merge_requests/#{iid}?state_event=close", "put")
        # puts "检查提交记录的code是#{haha["code"]}"
        # puts "检查提交记录的数据是#{haha["data"]}"
    end

    return status
end

get_resp = http_method("http://xx.x.xxx.xx:8000/api/v4/projects/#{$project_id}/merge_requests?state=opened", "get")
resp = JSON.parse(get_resp["data"])

if resp.empty?
    # # 1. 创建一个合并请求
    logger.info("新建合并分支请求")
    iid = ""
    body = '{"target_branch": "qa", "source_branch": "dev3.0", "title": "new request merge"}'
    create_merge = http_method("http://xx.x.xxx.xx:8000/api/v4/projects/#{$project_id}/merge_requests", "post", iid, body)
    status_code = create_merge["code"].to_i
    # 2. 合并分支
    if status_code == 201
        merge_data = JSON.parse(create_merge["data"])
        iid = merge_data["iid"]
        logger.info("合并请求的iid是#{iid}")
        #检查提交记录，如果没有就关闭合并请求
        logger.info("检查是否有提交")
        check_status = check_commit(iid)
        if check_status["code"] == 200
            logger.info("合并iid为#{iid}的分支")
            sleep 8
            merge_info = merge(iid)
	    merge_status = merge_info["code"].to_i
	    if merge_status != 200
	        logger.info("合并失败: #{merge_info["data"]}")
                exit
	    else
	        logger.info("#{iid}合并完成")
	    end
        else
            logger.info(check_status["data"])
            exit
        end
    end
else
    # # 1. 合并分支
    iid = resp[0]["iid"]
    logger.info("开始合并#{iid}分支")
    check_status = check_commit(iid)
    if check_status["code"] == 200
        logger.info("检查提交完成，开始合并")
        merge_info = merge(iid)
	merge_status = merge_info["code"].to_i
	if merge_status != 200
	    logger.info("合并失败: #{merge_info["data"]}")
	    exit
	else
	    logger.info("#{iid}合并完成")
	end
    else
        logger.info(check_status["data"])
        exit
    end
end

##################  gitlab  END  #################################

##################  jenkins模块构建 ################################
#
# 获取要发布的模块，通过jenkins接口来发布
logger.info("合并状态是: #{merge_info["code"]}")
if merge_info["code"].to_i == 200
    logger.info("合并成功，开始构建部署")
    begin
        deploy_file = ".deploying.txt"
        if File.exist?(deploy_file)
            module_list = IO.readlines(deploy_file)
            #File.delete(deploy_file)
            logger.info("需要发版的模块是#{module_list}")
        else
            logger.info("#{Time.now.hour}点不需要发版,退出")
            exit
        end
	post_uri = "#{jenkins_host}#{jenkins_module}#{jenkins_build}"
        get_uri = "#{jenkins_host}#{jenkins_module}#{jenkins_last_build}"
        module_list.uniq.each do |module_name|
	    mod = module_name.chomp
            logger.info("开始部署模块#{mod}")
            build_params = "json={\"parameter\":[{\"name\":\"environment\",\"value\":\"#{mod}\"}]}"
	    puts post_uri
            puts build_params
            resp_fun = post_response(post_uri, jenkins_user, jenkins_token, build_params)
            # 需要增加睡眠时间，因为post的请求不一定立刻能执行
            # 如果有多个一起构建，3秒还不一定满足
            sleep 3
            if resp_fun["code"] == "201"
		logger.info("提交到jenkins成功")
                haha = get_response(get_uri, jenkins_user, jenkins_token)
                build_value = JSON.parse(haha["body"])
                build_module_id = build_value["id"].to_i
                get_build_status_url = "http://xx.x.xxx.xx:8080/job/QA_backend/#{build_module_id}/api/json"
                begin
                    build_status_body = get_response(get_build_status_url, jenkins_user, jenkins_token)
                    build_status_value = JSON.parse(build_status_body["body"])
                    if build_status_value["result"] != "SUCCESS"
                        n = n + 1
                        sleep 10
                    else
                        logger.info("部署成功")
                    end
                end until n < 10
            else
                logger.warn("#{mod}部署失败: #{resp_fun["code"]}")
            end
        end
    end
else
    logger.warn("合并失败: #{merge_info["data"]}")
end
