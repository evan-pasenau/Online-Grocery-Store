<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
    String key = request.getParameter("key");
    if(key != null) {
        HashMap<String, ArrayList<Object>> productList = 
            (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
        
        if(productList != null && productList.containsKey(key)) {
            productList.remove(key);
            session.setAttribute("productList", productList);
        }
    }
    response.sendRedirect("showcart.jsp");
%>
