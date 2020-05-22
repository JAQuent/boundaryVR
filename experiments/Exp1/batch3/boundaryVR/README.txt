////////////////////////////////////////////////////////////////////
//////                 Boundary VR Exp 1					  ////// 
////////////////////////////////////////////////////////////////////


The experiment needs to be set-up in the following way on the JATOS server:
1.  get_prolific_id_url.html
2.  initial_browser_tests.html
3.  study_information.html
JSON input:
{
  "est_time": "35",
  "max_time": "50",
  "exp_title": "Spatial Experiment"
}

4.  consent.html
5.  pretest_instructions.html
6.  speed_test.html
7.  test_video_demo.html
8.  start_exp.html
JSON input:
{
  "counterbalance_control": "custom",
  "subjCond": 6
}

9.  show_vr_video.html
10. memoryTask.html
11. debrief.html
12. end_exp.html
{
  "url": "referral-link"
}