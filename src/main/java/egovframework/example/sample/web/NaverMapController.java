package egovframework.example.sample.web;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

import javax.net.ssl.HttpsURLConnection;

import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class NaverMapController {

	@RequestMapping("/naver_map.do")
	public String index() {
		return "index";
	}
	
	@RequestMapping(value = "/proxy.do", produces = "application/json" )
	@ResponseBody
	public String proxy(String urlStr) {
//		String start = req.getParameter("start");
//		String goal = req.getParameter("goal");
		JSONObject result=null;
		try {
//			String urlStr="https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=" + start + "&goal=" + goal;
			
			urlStr = URLDecoder.decode(urlStr, StandardCharsets.UTF_8.name()).replace("&amp;","&");
			System.out.println(urlStr);
			URL url = new URL(urlStr);
			HttpsURLConnection conn = (HttpsURLConnection)url.openConnection();
			
			conn.setRequestMethod("GET"); // http 메서드
//			conn.setRequestProperty("Content-Type", "application/json"); // header Content-Type 정보
			conn.setRequestProperty("X-NCP-APIGW-API-KEY-ID", "nn9o99r7mj"); // header의 auth 정보
			conn.setRequestProperty("X-NCP-APIGW-API-KEY", "BVChsbUpUyKDWL3AlDEo72VR97E7AGGTeKHcQY7b"); // header의 auth 정보
			conn.setDoOutput(true); // 서버로부터 받는 값이 있다면 true
			
			// 서버로부터 데이터 읽어오기
			BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			StringBuilder sb = new StringBuilder();
			String line = null;
			
			while((line = br.readLine()) != null) { // 읽을 수 있을 때 까지 반복
				sb.append(line);
			}
			
			result = new JSONObject(sb.toString()); // json으로 변경 (역직렬화)
//			System.out.println("code= " + result.getInt("code") + " / message= " + result.getString("message"));
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		return result.toString();
	}
}
