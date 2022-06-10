#!/usr/local/opt/ruby@3.1/bin/ruby

require 'net/http'
require 'uri'
require 'json'

$project_id = 275

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
    req["PRIVATE-TOKEN"] = "MNwzLpsvSx4gWCzwGweSd"
    resp = Net::HTTP.start(new_uri.hostname, new_uri.port) do |http|
        http.request(req, send_body)
    end
    return return_data(resp)
end

def merge(iid)
    resp = http_method("http://hostname/api/v4/projects/#{$project_id}/merge_requests/#{iid}/merge", "put", iid)
    resp_status = resp["code"].to_i
    if resp_status != 200
        puts "合并失败,原因是: #{resp["data"]}"
    else
        puts "合并完成"
    end

    return resp
end

#检查提交记录，如果没有就关闭合并请求
#如果不检查，在合并的时候会报错
def check_commit(iid)
    puts "检查提交记录"
    status = Hash.new()
    status["code"] = 200
    status["data"] = ""
    commit = http_method("http://hostname/api/v4/projects/#{$project_id}/merge_requests/#{iid}/commits", "get")
    commit_record = JSON.parse(commit["data"])
    if commit_record.empty?
        status["code"] = 499
        status["data"] = "提交记录为空，关闭合并请求"
        http_method("http://hostname/api/v4/projects/#{$project_id}/merge_requests/#{iid}?state_event=close", "put")
    end

    return status
end

get_resp = http_method("http://hostname/api/v4/projects/#{$project_id}/merge_requests?state=opened", "get")
resp = JSON.parse(get_resp["data"])

if resp.empty?
    # # 1. 创建一个合并请求
    puts "新建合并分支请求"
    iid = ""
    body = '{"target_branch": "qa", "source_branch": "dev", "title": "new request merge"}'
    create_merge = http_method("http://hostname/api/v4/projects/#{$project_id}/merge_requests", "post", iid, body)
    status_code = create_merge["code"].to_i
    # 2. 合并分支
    if status_code == 201
        merge_data = JSON.parse(create_merge["data"])
        iid = merge_data["iid"]
        check_status = check_commit(iid)
        if check_status["code"] == 200
            sleep 8
            merge_status = merge(iid)
        else
            puts check_status["data"]
        end
    end
else
    # # 1. 合并当前分支
    puts "合并当前分支请求"
    iid = resp[0]["iid"]
    check_status = check_commit(iid)
    if check_status["code"] == 200
        puts "开始合并"
        merge_status = merge(iid)
    else
        puts check_status["data"]
    end
end
