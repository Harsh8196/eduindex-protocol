import React from 'react';
import homebg from '../image/homebg.png'
import { Link } from 'react-router-dom';

function Home() {

    return (
        <div>
            <div className='row mt-5 m-1'>
                <div className="card text-bg-dark">
                    <img src={homebg} className="card-img" />
                        <div className="card-img-overlay align-content-center">
                            <h5>Lead the charge to new frontiers</h5>
                            <h3 className="card-title">Become a next gen developer </h3>
                            <p>Access free, full stack, high quality education to become a Web3 expert!</p>
                            <Link class="btn btn-CourseCatalog" to="/coursecatalog">
                                Start Learning</Link>
                        </div>
                </div>
            </div>
        </div>
    )
}


export default Home