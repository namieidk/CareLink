import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF8383),
                      Color(0xFFFF9B9B),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey[400],
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good Morning',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Dr. Martinez',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFEB3B),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFFFF8383),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickStat(
                              icon: Icons.people_outline,
                              count: '24',
                              label: 'Patients Today',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickStat(
                              icon: Icons.pending_actions,
                              count: '8',
                              label: 'Pending',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickStat(
                              icon: Icons.access_time,
                              count: '4h',
                              label: 'Available',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Today's Schedule Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Schedule",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Upcoming Appointments
                  _buildAppointmentCard(
                    time: '09:00 AM',
                    patientName: 'Maria Santos',
                    type: 'Follow-up Consultation',
                    status: 'Confirmed',
                    statusColor: Color(0xFF4CAF50),
                  ),
                  
                  SizedBox(height: 12),
                  
                  _buildAppointmentCard(
                    time: '10:30 AM',
                    patientName: 'John Dela Cruz',
                    type: 'Initial Consultation',
                    status: 'Waiting',
                    statusColor: Color(0xFFFFA726),
                  ),
                  
                  SizedBox(height: 12),
                  
                  _buildAppointmentCard(
                    time: '02:00 PM',
                    patientName: 'Ana Reyes',
                    type: 'Prescription Review',
                    status: 'Scheduled',
                    statusColor: Color(0xFF42A5F5),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Action Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        icon: Icons.person_add_outlined,
                        title: 'Add New\nPatient',
                        color: Color(0xFF6C5CE7),
                        gradient: [Color(0xFFE8D4F8), Color(0xFFD4C5F9)],
                      ),
                      _buildActionCard(
                        icon: Icons.medication_outlined,
                        title: 'Prescribe\nMedication',
                        color: Color(0xFFE17055),
                        gradient: [Color(0xFFFFE6C7), Color(0xFFFFD4AD)],
                      ),
                      _buildActionCard(
                        icon: Icons.analytics_outlined,
                        title: 'View\nAnalytics',
                        color: Color(0xFF00B894),
                        gradient: [Color(0xFFD4F8E8), Color(0xFFB8F2D9)],
                      ),
                      _buildActionCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Manage\nSchedule',
                        color: Color(0xFFD63031),
                        gradient: [Color(0xFFFFCFCF), Color(0xFFFFB8B8)],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildActivityItem(
                    icon: Icons.check_circle_outline,
                    title: 'Consultation completed',
                    subtitle: 'Pedro Garcia - 30 mins ago',
                    iconColor: Color(0xFF4CAF50),
                  ),
                  
                  _buildActivityItem(
                    icon: Icons.description_outlined,
                    title: 'Prescription issued',
                    subtitle: 'Rosa Martinez - 1 hour ago',
                    iconColor: Color(0xFF42A5F5),
                  ),
                  
                  _buildActivityItem(
                    icon: Icons.event_available,
                    title: 'New appointment booked',
                    subtitle: 'Carlos Ramos - 2 hours ago',
                    iconColor: Color(0xFFFFA726),
                  ),
                  
                  SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard, 'Dashboard', true),
                _buildNavItem(Icons.people, 'Patients', false),
                _buildNavItem(Icons.calendar_month, 'Schedule', false),
                _buildNavItem(Icons.medication, 'Prescriptions', false),
                _buildNavItem(Icons.settings, 'Settings', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String time,
    required String patientName,
    required String type,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  patientName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFF8383).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Color(0xFFFF6B6B) : Colors.grey[400],
                size: 26,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Color(0xFFFF6B6B) : Colors.grey[400],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}