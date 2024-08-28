import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Base from './component/Base';
import Home from './component/Home';
import MyCourse from './component/MyCourse';
import CourseCatalog from './component/CourseCatalog';
import CreateCourse from './component/CreateCourse';
import CreateProfile from './component/CreateProfile';
import ViewProfile from './component/ViewProfile';
import CourseDetails from './component/CourseDetails';
import CreateLesson from './component/CreateLesson';
import './App.css';

function App() {
  return (
    <Router>
    <Base />
      <Routes>
      <Route path="/" element={<Home />} />
        <Route path="/mycourse" element={<MyCourse />} />
        <Route path="/coursecatalog" element={<CourseCatalog />} />
        <Route path="/createcourse" element={<CreateCourse />} />
        <Route path="/createprofile" element={<CreateProfile />} />
        <Route path="/viewprofile" element={<ViewProfile />} />
        <Route path="/coursedetails/:pubid/:pubprofileid" element={<CourseDetails />} />
        <Route path="/createlesson/:pubid/:pubprofileid" element={<CreateLesson />} />
      </Routes>
  </Router>
  );

}

export default App;
