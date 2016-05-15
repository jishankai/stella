# coding: utf-8
require 'csv'

namespace :spiders do
  desc "获取链家中介信息"
  task :lfetch, [:url] => :environment do |t, args|
    i = *(1..100)
    urls = i.map { |x| args[:url] + x.to_s }
    @sheet = []

    Anemone.crawl(urls, {:user_agent => "AnemoneCrawler/0.0.1", :delay => 1, :depth_limit => 1}) do |anemone|
      #anemone.storage = Anemone::Storage.Redis
      PATTERN = %r[#{args[:url]+'\d+'}]
      anemone.focus_crawl do |page|
        page.links.keep_if { |link|
          link.to_s.match(PATTERN)
        }
      end

      anemone.on_every_page do |page|
        puts page.url
        page.doc.search('ul.agent-lst li').each do |r|
          row = {}
          row[:img] = r.search('img').attribute('src').value
          row[:name] = r.search('.agent-name h2').text
          row[:position] = r.search('span.position').text
          row[:plate] = ""
          r.search('.main-plate span a').each do |m|
            row[:plate] += m.text
            row[:plate] += " "
          end
          row[:achievement] = ""
          r.search('.achievement span').each do |a|
            row[:achievement] += a.text
            row[:achievement] += " "
          end
          row[:label] = ""
          r.search('.label span').each do |l|
            row[:label] += l.text
            row[:label] += " "
          end
          row[:rates] = r.search('.high-praise span.num').text
          row[:votes] = r.search('.comment-num').text
          row[:mobile] = r.search('.col-3 h2').text
          @sheet.push(row)
        end
      end
    end
    f = "/Users/jishankai/Desktop/链家经纪人_utf8.csv"
    CSV.open(f, "wb") do |csv|
      csv << ["照片", "姓名", "职位", "主营板块", "数据", "标签", "好评率", "评论数量", "电话"]
      @sheet.each do |hash|
        csv << hash.values
      end
    end
  end

  desc "获取我爱我家中介信息"
  task :wfetch, [:url] => :environment do |t, args|
    i = *(1..100)
    urls = i.map { |x| args[:url] + x.to_s }
    @sheet = []
    Anemone.crawl(urls, {:user_agent => "AnemoneCrawler/0.0.1", :delay => 1, :depth_limit => 0}) do |anemone|
      #anemone.storage = Anemone::Storage.Redis
      PATTERN = %r[#{args[:url]+"\\d+"}]
      anemone.focus_crawl do |page|
        page.links.keep_if { |link|
          link.to_s.match(PATTERN)
        }
      end

      anemone.on_every_page do |page|
        puts page.url
        page.doc.search('.zhiye_content .consinfo').each do |r|
          row = {}
          row[:image] = r.search('dl.leftfuwusty dt img').attribute('src').value
          row[:name] = r.search('.conts_left span').text
          row[:mobile] = r.search('.conts_left b').text
          row[:plate] = ""
          r.search('dl.leftfuwusty dd a.mr5').each do |p|
            row[:plate] += p.text
            row[:plate] += " "
          end
          row[:community] = ""
          r.search('dl.leftfuwusty dd.asty a').each do |c|
            row[:community] += c.text
            row[:community] += " "
          end
          row[:sale] = r.search('dl.leftfuwusty dd.shouzu span.f3d').text
          row[:rent] = r.search('dl.leftfuwusty dd.shouzu span.fcf0').text
          row[:rates] = r.search('dl.leftfuwusty dd.pinglunxin b').count
          row[:followers] = r.search('dl.leftfuwusty dd.guanzhudu span').first.text
          row[:clicks] = r.search('dl.leftfuwusty dd.guanzhudu span').last.text
          @sheet.push(row)
          #byebug
        end
      end
    end
    f = "/Users/jishankai/Desktop/我爱我家经纪人.csv"
    CSV.open(f, "wb") do |csv|
      csv << ["照片", "姓名", "电话", "商圈", "小区", "售", "租", "好评度", "关注度", "点击量"]
      @sheet.each do |hash|
        csv << hash.values
      end
    end
  end

  desc "获取麦田中介信息"
  task :mfetch, [:url, :n] => :environment do |t, args|
    n = args[:n].to_i
    i = *(1..n)
    urls = i.map { |x| args[:url] + x.to_s }
    @sheet = []
    Anemone.crawl(urls, {:user_agent => "AnemoneCrawler/0.0.1", :delay => 1, :depth_limit => 0}) do |anemone|
      #anemone.storage = Anemone::Storage.Redis
      PATTERN = %r[#{args[:url]+"\\d+"}]
      anemone.focus_crawl do |page|
        page.links.keep_if { |link|
          link.to_s.match(PATTERN)
        }
      end

      anemone.on_every_page do |page|
        puts page.url
        page.doc.search('.list_wrap .clearfix').each do |r|
          row = {}
          row[:image] = r.search('.agent_man dt img').attribute('src').value
          row[:name] = r.search('.agent_man ol li.top a').text
          row[:mobile] = r.search('.agent_man ol li.top kbd').text
          row[:plate] = r.search('.agent_man ol li')[1].text.gsub!(/\s/, " ")
          row[:sale] = r.search('.agent_man ol li')[1].search('a').first.text
          row[:rent] = r.search('.agent_man ol li')[1].search('a').last.text
          row[:label] = ""
          r.search('.agent_man ol li.characteristics label span').each do |l|
            row[:label] += l.text
            row[:label] += " "
          end
          row[:years] = r.search('.four_title dd span').first.text
          row[:customers] = r.search('.four_title dd span')[1].text
          row[:deal] = r.search('.four_title dd span')[2].text
          row[:followers] = r.search('.four_title dd span').last.text
          row[:stars] = r.search('.agent_man dd label').count
          @sheet.push(row)
        end
      end
    end
    f = "/Users/jishankai/Desktop/麦田经纪人.csv"
    CSV.open(f, "wb") do |csv|
      csv << ["照片", "姓名", "电话", "商圈", "售", "租", "标签", "从业年限", "客户数", "近期成交", "粉丝数", "星级"]
      @sheet.each do |hash|
        csv << hash.values
      end
    end
  end

  desc "删除中介信息"
  task erase: :environment do
  end

  desc "更新链家中介信息"
  task :lupdate, [:url] => :environment do |t, args|
    # i = *(1..100)
    # urls = i.map { |x| args[:url] + x.to_s }
    # s = []
    # Anemone.crawl(urls, {:user_agent => "AnemoneCrawler/0.0.1", :delay => 1, :depth_limit => 0}) do |anemone|
    #   #anemone.storage = Anemone::Storage.Redis
    #   PATTERN = %r[#{args[:url]+'\d+'}]
    #   anemone.focus_crawl do |page|
    #     page.links.keep_if { |link|
    #       link.to_s.match(PATTERN)
    #     }
    #   end

    #   anemone.on_every_page do |page|
    #     u = [] # 经纪人个人页面URL集合
    #     puts page.url
    #     page.doc.search('ul.agent-lst li').each do |r|
    #       u.push(r.search('.agent-name a').attribute('href').value)
    #     end
    #     #byebug
    #     s.push(u)
    #   end
    # end
    f = "/Users/jishankai/Desktop/链家经纪人_链接.csv"
    # CSV.open(f, "wb") do |csv|
    #   s.each do |arr|
    #     csv << arr
    #   end
    # end

    arr_of_arrs = CSV.read(f)
    urls_of_agents = arr_of_arrs.flatten(1)
    @sheet = []
    f = "/Users/jishankai/Desktop/链家经纪人_手机.csv"
    # CSV.open(f, "wb") do |csv|
    #   csv << ["姓名", "手机", "小区", "链接"]
    # end
    # byebug
    Anemone.crawl(urls_of_agents, {:user_agent => "AnemoneCrawler/0.0.1", :delay => 1, :depth_limit => 0, :discard_page_bodies => true}) do |anemone|
      #anemone.storage = Anemone::Storage.Redis
      AGENTPATTERN = %r[http://\d+.dianpu.lianjia.com]
      anemone.focus_crawl do |page|
        page.links.keep_if { |link|
          link.to_s.match(AGENTPATTERN)
        }
      end
      i = 0
      anemone.on_every_page do |page|
        puts page.url
        row = {}
        row[:name] = page.doc.search('.agent-name a h1').text
        row[:mobile] = page.doc.at('title').inner_html.gsub!(/\D/, "")
        row[:community] = ""
        page.doc.search('.info_bottom p').last.search('a').each do |r|
          row[:community] += r.text
          row[:community] += " "
        end
        row[:url] = page.url.to_s
        # byebug
        @sheet.push(row)
        i += 1
        CSV.open(f, "ab") do |csv|
          @sheet.each do |hash|
            csv << hash.values
          end
          @sheet.clear
        end if i % 30 == 0
      end
    end

  end

end
