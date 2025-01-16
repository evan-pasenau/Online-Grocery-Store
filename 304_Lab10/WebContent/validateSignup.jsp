<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

	try
	{
	    authenticatedUser = validateSignup(out,request,session);
	}
	catch(IOException e)
	{	System.err.println(e); }

	if(authenticatedUser != null)
		response.sendRedirect("index.jsp");		// Successful signUp
	else
		response.sendRedirect("signup.jsp");	// Failed Sign Up - redirect back to signup page with a message 
%>


<%!
	String validateSignup(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException
	{
		String username = request.getParameter("username");
		String password = request.getParameter("password");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneNum = request.getParameter("phoneNum");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String postalCode = request.getParameter("postalCode");
        String country = request.getParameter("country");

		String retStr = null;
        int rowIns = 0;

		if (username == null || password == null || firstName == null || lastName == null || email == null || phoneNum == null || address == null || city == null || state == null || postalCode == null || country == null)
			return null;
        if ((firstName.length() == 0) || (lastName.length() == 0) || (email.length() == 0) || (phoneNum.length() == 0) || (address.length() == 0) || (city.length() == 0) || (state.length() == 0) || (postalCode.length() == 0) || (country.length() == 0)) {
            return null;
        }


		try 
		{
            getConnection();
            Statement stmt = con.createStatement(); 
            stmt.execute("USE orders");
            String sql = "INSERT INTO customer (firstName, lastName, email, phoneNum, address, city, state, postalCode, country, userid, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, email);
            pstmt.setString(4, phoneNum);
            pstmt.setString(5, address);
            pstmt.setString(6, city);
            pstmt.setString(7, state);
            pstmt.setString(8, postalCode);               
            pstmt.setString(9, country);
            pstmt.setString(10, username);
            pstmt.setString(11, password);

            rowIns = pstmt.executeUpdate();
            
		}
		catch (SQLException ex) {
			out.println(ex);
		}
		finally
		{
			closeConnection();
		}	
		
		if((rowIns > 0))
		{	
            session.removeAttribute("loginMessage");
			session.setAttribute("authenticatedUser", username);
            retStr = username;
		}
		else
			session.setAttribute("loginMessage","Could not sign up using that Sign-Up information");
        return retStr;
	}
%>

