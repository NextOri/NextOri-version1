import Navbar from "../components/Navbar";
import Footer from "../components/Footer";


import HeroSection from "../components/HeroSection";
import FeaturesSection from "../components/FeaturesSection";
import CTASection from "../components/CTASection";
import AboutSection from "../components/AboutSection";


import "../styles/Home.css";



function Home(){

    return(

        <>

            <Navbar />

            <HeroSection />

            <FeaturesSection />

            <AboutSection />

            <CTASection />

            <Footer />

            

        </>

    );

}


export default Home;